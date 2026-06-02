defmodule TippingWeb.AuthTest do
  use TippingWeb.ConnCase

  import Tipping.AccountsFixtures

  alias TippingWeb.Auth

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{}), user: user_fixture(), admin_user: admin_user_fixture()}
  end

  describe "fetch_current_user/2" do
    test "does not assign a user if data is missing", %{conn: conn} do
      conn = Auth.fetch_current_user(conn, [])
      refute conn.assigns.user
    end

    test "assigns a user given a valid user ID in the session", %{conn: conn, user: user} do
      conn = conn |> put_session(:user_id, user.id) |> Auth.fetch_current_user([])
      assert conn.assigns.user.id == user.id
    end
  end

  describe "require_authenticated_user/2" do
    setup %{conn: conn} do
      %{conn: Auth.fetch_current_user(conn, [])}
    end

    test "does nothing when a user is logged in", %{conn: conn, user: user} do
      conn = conn |> assign(:user, user) |> Auth.require_authenticated_user([])

      refute conn.halted
      refute conn.status
    end

    test "redirects when a user is not logged in", %{conn: conn} do
      conn = conn |> fetch_flash() |> Auth.require_authenticated_user([])
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info)
      assert conn.halted
    end
  end

  describe "redirect_authenticated_user/2" do
    setup %{conn: conn} do
      %{conn: Auth.fetch_current_user(conn, [])}
    end

    test "does nothing when no user is logged in", %{conn: conn} do
      conn = Auth.redirect_authenticated_user(conn, [])

      refute conn.halted
      refute conn.status
    end

    test "redirects authenticated user to /kamper", %{conn: conn, user: user} do
      conn = conn |> assign(:user, user) |> Auth.redirect_authenticated_user([])
      assert redirected_to(conn) == ~p"/kamper"
      assert conn.halted
    end
  end

  describe "require_admin_user/2" do
    setup %{conn: conn} do
      %{conn: Auth.fetch_current_user(conn, [])}
    end

    test "raises 404 when no user is logged in", %{conn: conn} do
      assert_raise(Phoenix.Router.NoRouteError, fn -> Auth.require_admin_user(conn, []) end)
    end

    test "raises 404 when a non-admin user is logged in", %{conn: conn, user: user} do
      assert_raise(Phoenix.Router.NoRouteError, fn ->
        conn |> assign(:user, user) |> Auth.require_admin_user([])
      end)
    end

    test "does nothing when admin user is logged in", %{conn: conn, admin_user: user} do
      conn = conn |> assign(:user, user) |> Auth.require_admin_user([])
      refute conn.status
      refute conn.halted
    end
  end

  describe "require_valid_bearer_token/2" do
    test "returns a 401 when no header is present", %{conn: conn} do
      conn = Auth.require_valid_bearer_token(conn, [])
      assert conn.status == 401
      assert conn.halted
    end

    test "returns a 401 when an invalid token is present", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "bearer this-aint-it")
        |> Auth.require_valid_bearer_token([])

      assert conn.status == 401
      assert conn.halted
    end

    test "assigns the user when given a valid key", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> put_req_header("authorization", "bearer #{user.api_key}")
        |> Auth.require_valid_bearer_token([])

      refute conn.status
      refute conn.halted
      assert conn.assigns.user.id == user.id
    end
  end

  describe "on_mount: require_authenticated" do
    test "authenticates given a valid user ID in the session", %{conn: conn, user: user} do
      session = conn |> put_session(:user_id, user.id) |> get_session()

      {:cont, updated_socket} =
        Auth.on_mount(:require_authenticated, %{}, session, %Phoenix.LiveView.Socket{})

      assert updated_socket.assigns.user.id == user.id
    end

    test "redirects if there is no user in the session", %{conn: conn} do
      session = get_session(conn)

      socket = %Phoenix.LiveView.Socket{
        endpoint: TippingWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} =
        Auth.on_mount(:require_authenticated, %{}, session, socket)

      assert updated_socket.assigns.user == nil
    end
  end

  describe "on_mount: require_admin" do
    test "redirects if there is no user in the session", %{conn: conn} do
      session = get_session(conn)

      assert {:halt, updated_socket} =
               Auth.on_mount(:require_admin, %{}, session, %Phoenix.LiveView.Socket{})

      assert updated_socket.assigns.user == nil
    end

    test "redirects if a non-admin user is logged in", %{conn: conn, user: user} do
      session = conn |> put_session(:user_id, user.id) |> get_session()

      assert {:halt, updated_socket} =
               Auth.on_mount(:require_admin, %{}, session, %Phoenix.LiveView.Socket{})

      assert updated_socket.assigns.user.id == user.id
    end

    test "does nothing if an admin is logged in", %{conn: conn, admin_user: user} do
      session = conn |> put_session(:user_id, user.id) |> get_session()

      assert {:cont, %Phoenix.LiveView.Socket{}} =
               Auth.on_mount(:require_admin, %{}, session, %Phoenix.LiveView.Socket{})
    end
  end
end

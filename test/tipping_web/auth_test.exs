defmodule TippingWeb.AuthTest do
  use TippingWeb.ConnCase

  import Tipping.AccountsFixtures

  alias TippingWeb.Auth

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{}), user: user_fixture()}
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
end

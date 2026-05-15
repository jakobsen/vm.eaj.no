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
end

defmodule TippingWeb.PageControllerTest do
  use TippingWeb.ConnCase

  import Tipping.AccountsFixtures

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "fotball"
  end

  test "GET /?error=ikke-bedriftskonto", %{conn: conn} do
    conn = get(conn, ~p"/?feil=ikke-bedriftskonto")

    assert html_response(conn, 200) =~
             "Du må logge inn med en Google-konto tilknyttet et Workspace"
  end

  test "GET /regler", %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> init_test_session(%{})
      |> Plug.Conn.put_session(:user_id, user.id)
      |> get(~p"/regler")

    assert html_response(conn, 200) =~ "Regler"
  end
end

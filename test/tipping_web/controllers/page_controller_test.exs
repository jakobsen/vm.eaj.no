defmodule TippingWeb.PageControllerTest do
  use TippingWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "fotball"
  end

  test "GET /?error=ikke-bedriftskonto", %{conn: conn} do
    conn = get(conn, ~p"/?feil=ikke-bedriftskonto")

    assert html_response(conn, 200) =~
             "Du må logge inn med en Google-konto tilknyttet et Workspace"
  end
end

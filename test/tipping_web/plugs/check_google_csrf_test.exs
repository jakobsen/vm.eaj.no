defmodule TippingWeb.CheckGoogleCsrfTest do
  use TippingWeb.ConnCase, async: true

  alias TippingWeb.CheckGoogleCsrf

  @csrf_key "g_csrf_token"

  defp build_conn_with(cookie: cookie, param: param) do
    Phoenix.ConnTest.build_conn(:post, ~p"/auth-callback", %{})
    |> maybe_put_cookie(cookie)
    |> maybe_put_param(param)
    |> Plug.Test.init_test_session(%{})
  end

  defp maybe_put_cookie(conn, nil), do: conn
  defp maybe_put_cookie(conn, token), do: Plug.Test.put_req_cookie(conn, @csrf_key, token)

  defp maybe_put_param(conn, nil), do: conn
  defp maybe_put_param(conn, token), do: %{conn | params: Map.put(conn.params, @csrf_key, token)}

  test "passes through unchanged when cookie and param match" do
    conn = build_conn_with(cookie: "test", param: "test") |> CheckGoogleCsrf.call([])
    refute conn.halted
    assert is_nil(conn.status)
  end

  test "halts and redirects to / when cookie and param don't match" do
    conn = build_conn_with(cookie: "test", param: "another-test") |> CheckGoogleCsrf.call([])
    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end

  test "halts and redirects to / when cookie is missing" do
    conn = build_conn_with(cookie: nil, param: "test") |> CheckGoogleCsrf.call([])
    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end

  test "halts and redirects to / when param is missing" do
    conn = build_conn_with(cookie: "test", param: nil) |> CheckGoogleCsrf.call([])
    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end

  test "halts and redirects when token is empty string" do
    conn = build_conn_with(cookie: "", param: "") |> CheckGoogleCsrf.call([])
    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end
end

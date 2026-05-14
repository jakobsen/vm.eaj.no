defmodule TippingWeb.CheckGoogleCsrf do
  @moduledoc """
  Check the g_csrf cookie against the given param.
  Denies the request if they don't match.

  For details, see https://developers.google.com/identity/gsi/web/reference/html-reference#id-token-handler-endpoint
  """
  import Plug.Conn
  use TippingWeb, :verified_routes

  @g_csrf_key "g_csrf_token"

  def init(opts), do: opts

  def call(conn, _opts) do
    cookies_token =
      fetch_cookies(conn)
      |> Map.fetch!(:cookies)
      |> Map.get(@g_csrf_key)

    params_token = Map.get(conn.params, @g_csrf_key)

    cond do
      blank?(cookies_token) -> deny_login(conn)
      blank?(params_token) -> deny_login(conn)
      not Plug.Crypto.secure_compare(cookies_token, params_token) -> deny_login(conn)
      :else -> conn
    end
  end

  defp deny_login(conn) do
    conn
    |> fetch_session()
    |> Phoenix.Controller.fetch_flash()
    |> Phoenix.Controller.put_flash(:error, "Kunne ikke logge inn, prøv igjen")
    |> Phoenix.Controller.redirect(to: ~p"/")
    |> halt()
  end

  defp blank?(token), do: token == nil or token == ""
end

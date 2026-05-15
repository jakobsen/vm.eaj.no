defmodule TippingWeb.Auth do
  use TippingWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Tipping.Accounts

  def fetch_current_user(conn, _opts) do
    get_session(conn, :user_id)
    |> Accounts.get_user_by_id()
    |> then(&assign(conn, :user, &1))
  end

  def require_authenticated_user(conn, _opts) do
    case conn.assigns.user do
      nil ->
        conn
        |> put_flash(:info, "Du må være logget inn for å se denne siden.")
        |> redirect(to: ~p"/")
        |> halt()

      %Accounts.User{} ->
        conn
    end
  end
end

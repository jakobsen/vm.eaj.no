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

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:info, "Du må være logget inn for å se denne siden.")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :user, fn ->
      session
      |> Map.get("user_id")
      |> Accounts.get_user_by_id()
    end)
  end
end

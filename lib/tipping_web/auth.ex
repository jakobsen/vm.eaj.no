defmodule TippingWeb.Auth do
  use TippingWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Tipping.Accounts

  def log_in_user(conn, %Accounts.User{} = user) do
    conn
    |> renew_session(user)
    |> put_session(:user_id, user.id)
    |> redirect(to: ~p"/kamper")
  end

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

  def redirect_authenticated_user(conn, _opts) do
    case conn.assigns.user do
      nil ->
        conn

      %Accounts.User{} ->
        conn
        |> redirect(to: ~p"/kamper")
        |> halt()
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

  defp renew_session(conn, user) when conn.assigns.user.id == user.id, do: conn

  defp renew_session(conn, _user) do
    delete_csrf_token()

    conn |> configure_session(renew: true) |> clear_session()
  end
end

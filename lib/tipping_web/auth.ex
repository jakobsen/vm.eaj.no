defmodule TippingWeb.Auth do
  import Plug.Conn

  alias Tipping.Accounts

  def fetch_current_user(conn, _opts) do
    get_session(conn, :user_id)
    |> Accounts.get_user_by_id()
    |> then(&assign(conn, :user, &1))
  end
end

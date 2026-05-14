defmodule TippingWeb.AuthController do
  use TippingWeb, :controller

  def log_in(conn, params) do
    dbg()
    redirect(conn, to: ~p"/")
  end
end

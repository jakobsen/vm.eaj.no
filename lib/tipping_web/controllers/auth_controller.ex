defmodule TippingWeb.AuthController do
  use TippingWeb, :controller

  alias Tipping.Auth

  def log_in(conn, %{"credential" => jwt}) do
    Auth.GoogleJwt.verify_and_validate(jwt) |> dbg()
    redirect(conn, to: ~p"/")
  end
end

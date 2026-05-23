defmodule TippingWeb.HealthController do
  use TippingWeb, :controller

  def health(conn, _params) do
    json(conn, %{status: "healthy"})
  end
end

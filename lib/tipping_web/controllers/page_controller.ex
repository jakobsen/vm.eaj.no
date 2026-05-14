defmodule TippingWeb.PageController do
  use TippingWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

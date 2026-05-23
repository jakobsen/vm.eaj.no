defmodule TippingWeb.PointsTableLive do
  use TippingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :body_class, "bg-dark-blue")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_page={:tabell} flash={@flash}>
      Hei {@user.name}!
    </Layouts.app>
    """
  end
end

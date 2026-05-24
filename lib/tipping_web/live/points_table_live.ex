defmodule TippingWeb.PointsTableLive do
  use TippingWeb, :live_view

  import TippingWeb.PointsTableComponents

  alias Tipping.Game

  @impl true
  def mount(_params, _session, socket) do
    scores =
      socket.assigns.user
      |> Game.organization_scoreboard()
      |> prepare_table()

    {:ok, socket |> assign(:body_class, "bg-dark-blue") |> assign(:scores, scores)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_page={:tabell} flash={@flash}>
      <h1 class="large-heading mb-10">Tabell</h1>
      <p class="mb-3">Stillingen i {@user.organization} så langt:</p>
      <.scoreboard scores={@scores} />
    </Layouts.app>
    """
  end

  @doc """
  Adds a position attribute to a list of maps containing a points attribute.
  The maps are expected to be sorted in descending order by points.
  Handles ties.
  """
  def prepare_table([]), do: []

  def prepare_table(scores) do
    {updated_scores, _acc} =
      scores
      |> Enum.with_index(1)
      |> Enum.map_reduce(%{points: :infinity}, fn {row, idx}, prev_row ->
        position = if row.points == prev_row.points, do: prev_row.position, else: idx

        updated_row =
          row
          |> Map.put(:position, position)
          |> Map.put(:name, row.user.name)
          |> Map.delete(:user)

        {updated_row, updated_row}
      end)

    updated_scores
  end
end

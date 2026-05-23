defmodule TippingWeb.Admin.MatchesLive do
  use TippingWeb, :live_view

  alias Tipping.WorldCup
  alias TippingWeb.Layouts

  def mount(_params, _session, socket) do
    matches = WorldCup.list_matches()
    {:ok, assign(socket, :matches, matches)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash}>
      <.table id="matches-table" rows={@matches}>
        <:col :let={match} label="Avspark">{format_kickoff(match)}</:col>
        <:col :let={match} label="Type">{match.stage}</:col>
        <:col :let={match} label="Hjemmelag">{get_in(match.home_team.name)}</:col>
        <:col :let={match} label="Bortelag">{get_in(match.away_team.name)}</:col>
        <:col :let={match} label="Mål hjemme">{match.home_score}</:col>
        <:col :let={match} label="Mål borte">{match.away_score}</:col>

        <:action :let={match}>
          <.link navigate={~p"/admin/kamper/#{match}"}>Oppdater</.link>
        </:action>
      </.table>
    </Layouts.admin>
    """
  end

  defp format_kickoff(%{kickoff_at: kickoff}) do
    Calendar.strftime(kickoff, "%-d.%-m. %H.%M")
  end
end

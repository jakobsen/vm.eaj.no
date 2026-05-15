defmodule TippingWeb.MatchListLive do
  use TippingWeb, :live_view

  alias Tipping.WorldCup

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, matches: WorldCup.list_matches())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <ul>
      <li :for={match <- @matches}>
        {match.stage}, spilles {match.kickoff_at}
        <br />
        <img height="24" width="24" src={~p"/images/flags/MEX.svg"} />
        {get_in(match.home_team.name) || "?"} vs. {get_in(match.away_team.name) || "?"}
      </li>
    </ul>
    """
  end
end

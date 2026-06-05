defmodule TippingWeb.Admin.MatchStoriesLive do
  use TippingWeb, :live_view

  import TippingWeb.MatchComponents

  alias Tipping.Game
  alias Tipping.WorldCup

  def mount(_params, _session, socket) do
    [home_team, away_team | _] = WorldCup.list_teams() |> Enum.shuffle()

    {:ok,
     assign(socket,
       bet_without_score: %Game.Bet{match_id: 1, home_score: nil, away_score: nil},
       bet_with_score: %Game.Bet{match_id: 1, home_score: 2, away_score: 2},
       match: %WorldCup.Match{
         id: 1,
         home_team_id: home_team.id,
         home_team: home_team,
         away_team_id: away_team.id,
         away_team: away_team,
         kickoff_at: ~U[2026-06-11 17:00:00Z],
         stage: "Testspill"
       },
       match_with_score: %WorldCup.Match{
         id: 1,
         home_team_id: home_team.id,
         home_team: home_team,
         away_team_id: away_team.id,
         away_team: away_team,
         home_score: 2,
         away_score: 1,
         kickoff_at: ~U[2026-06-11 17:00:00Z],
         stage: "Testspill"
       },
       match_without_teams: %WorldCup.Match{
         id: 1,
         kickoff_at: ~U[2026-06-11 17:00:00Z],
         stage: "Testspill",
         home_team: nil,
         away_team: nil
       }
     )}
  end

  def render(assigns) do
    ~H"""
    <main class="bg-dark-blue text-off-white p-10 max-w-xl mx-auto">
      <h2 class="text-2xl my-6">Åpen kamp</h2>
      <.match_card bet={@bet_without_score} match={@match} status={:open} />

      <h2 class="text-2xl my-6">Låst kamp, uten tipp</h2>
      <.match_card match={@match} status={:locked} />

      <h2 class="text-2xl my-6">Låst kamp, med tipp</h2>
      <.match_card bet={@bet_with_score} match={@match} status={:locked} />

      <h2 class="text-2xl my-6">Ferdigspilt kamp, med tipp</h2>
      <.match_card bet={@bet_with_score} match={@match_with_score} status={:complete} />

      <h2 class="text-2xl my-6">Fremtidig kamp uten lag</h2>
      <.match_card bet={@bet_without_score} match={@match_without_teams} status={:disabled} />
    </main>
    """
  end

  def handle_event(_, _, socket) do
    {:noreply, socket}
  end
end

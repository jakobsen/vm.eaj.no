defmodule TippingWeb.MatchComponents do
  use TippingWeb, :verified_routes
  use Phoenix.Component

  alias Tipping.Game
  alias Tipping.WorldCup

  attr :bet, Game.Bet
  attr :match, WorldCup.Match

  def match_card(assigns) do
    ~H"""
    <article class="relative bg-gray-200 p-5 rounded">
      <p class="absolute top-0 -translate-y-1/4 right-5 bg-gray-700 rounded-full text-gray-300 text-sm px-2 py-1">
        {@match.stage}
      </p>
      <p class="mb-5">{format_kickoff_time(@match.kickoff_at)}</p>

      <div class="flex items-center justify-between">
        <.team_display team={@match.home_team} />
        <.bet_display bet={@bet} />
        <.team_display team={@match.away_team} />
      </div>
    </article>
    """
  end

  attr :bet, Game.Bet

  defp bet_display(%{bet: nil} = assigns) do
    ~H"""
    <div>
      <.bet_pill /> – <.bet_pill />
    </div>
    """
  end

  defp bet_display(assigns) do
    ~H"""
    <div class="text-2xl">
      <.bet_pill score={@bet.home_score} /> – <.bet_pill score={@bet.away_score} />
    </div>
    """
  end

  attr :score, :integer, default: nil

  defp bet_pill(assigns) do
    ~H"""
    <span class="min-w-[3ch] text-center font-semibold tabular-nums p-1 bg-gray-800 text-gray-200 inline-block rounded">
      {@score || "–"}
    </span>
    """
  end

  attr :team, WorldCup.Team

  defp team_display(assigns) do
    ~H"""
    <div class="flex flex-col items-center text-center w-30 max-w-30">
      <.flag team={@team} />
      {get_in(@team.name) || "—"}
    </div>
    """
  end

  attr :team, WorldCup.Team

  defp flag(%{team: nil} = assigns) do
    ~H"""
    <div class="size-10 rounded-full text-white text-2xl font-semibold bg-gray-700 grid place-items-center">
      ?
    </div>
    """
  end

  defp flag(assigns) do
    ~H"""
    <img
      class="size-10 rounded-full"
      src={static_path(TippingWeb.Endpoint, "/images/flags/#{@team.fifa_code}.svg")}
    />
    """
  end

  defp format_kickoff_time(%DateTime{} = kickoff) do
    kickoff |> DateTime.shift_zone!("Europe/Oslo") |> Calendar.strftime("%H:%M")
  end
end

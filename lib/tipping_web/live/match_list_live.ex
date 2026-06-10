defmodule TippingWeb.MatchListLive do
  use TippingWeb, :live_view

  import TippingWeb.MatchComponents

  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.WorldCup

  @impl true

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       matches_by_day: matches_with_bets_grouped_by_day(socket.assigns.user)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_page={:kamper}>
      <h1 class="text-center font-bold text-xl mb-3">Tipp i vei!</h1>
      <p class="text-center text-sm mb-8">Kampene låses 10 min før avspark.</p>
      <div class="relative pt-12">
        <div class="absolute top-0 bottom-0 left-1/2 w-px -translate-x-[0.5px] bg-white" />
        <div class="relative">
          <%= for {day, entries} <- @matches_by_day do %>
            <.day_label date={day} />
            <div class="flex flex-col gap-8 mx-auto mb-10">
              <.match_card
                :for={entry <- entries}
                bet={entry.bet}
                match={entry.match}
                status={entry.status}
                points={entry.points}
              />
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("place-bet", %{"home" => home, "away" => away, "match_id" => match_id}, socket) do
    with %WorldCup.Match{} = match <- WorldCup.get_match(String.to_integer(match_id)) do
      Game.place_bet(socket.assigns.user, match, %{home_score: home, away_score: away})
    end

    {:noreply,
     assign(socket,
       matches_by_day: matches_with_bets_grouped_by_day(socket.assigns.user)
     )}
  end

  @impl true
  def handle_event(
        "recover-bet",
        %{"home" => home, "away" => away, "match_id" => match_id},
        socket
      ) do
    if home == "" or away == "" do
      {:noreply, socket}
    else
      with %WorldCup.Match{} = match <- WorldCup.get_match(String.to_integer(match_id)) do
        Game.place_bet(socket.assigns.user, match, %{home_score: home, away_score: away})
      end

      {:noreply,
       assign(socket,
         matches_by_day: matches_with_bets_grouped_by_day(socket.assigns.user)
       )}
    end
  end

  def matches_with_bets_grouped_by_day(%Accounts.User{} = user) do
    now = DateTime.utc_now()

    WorldCup.list_matches_with_bets(user)
    |> Enum.map(fn entry ->
      entry
      |> Map.put(:status, match_status(entry.match, now))
      |> Map.put(:points, Game.bet_points(entry.bet, entry.match))
    end)
    |> Enum.map(fn entry ->
      update_in(entry.match.kickoff_at, &DateTime.shift_zone!(&1, "Europe/Oslo"))
    end)
    |> Enum.group_by(&DateTime.to_date(&1.match.kickoff_at))
    |> Map.to_list()
    |> Enum.sort_by(fn {date, _} -> date end, Date)
  end

  def match_status(%WorldCup.Match{} = match, now \\ DateTime.utc_now()) do
    cond do
      match.home_team_id == nil or match.away_team_id == nil -> :disabled
      match.home_score != nil and match.away_score != nil -> :complete
      DateTime.diff(match.kickoff_at, now, :second) <= 600 -> :locked
      true -> :open
    end
  end
end

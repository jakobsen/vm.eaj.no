defmodule TippingWeb.MatchListLive do
  use TippingWeb, :live_view

  import TippingWeb.MatchComponents

  alias Tipping.Game
  alias Tipping.WorldCup

  @impl true

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       matches_by_day: WorldCup.matches_with_bets_grouped_by_day(socket.assigns.user)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="p-5">
      <h1 class="font-bold text-4xl mb-5">Alle kamper</h1>
      <%= for {day, entries} <- @matches_by_day do %>
        <h2 class="font-bold text-2xl mb-2.5">{format_day(day)}</h2>
        <div class="flex flex-col gap-8 max-w-lg mx-auto mb-10">
          <.match_card
            :for={entry <- entries}
            bet={entry.bet}
            match={entry.match}
          />
        </div>
      <% end %>
    </main>
    """
  end

  @impl true
  def handle_event("place-bet", %{"home" => home, "away" => away, "match_id" => match_id}, socket) do
    with %WorldCup.Match{} = match <- WorldCup.get_match(String.to_integer(match_id)) do
      Game.place_bet(socket.assigns.user, match, %{home_score: home, away_score: away})
    end

    {:noreply,
     assign(socket,
       matches_by_day: WorldCup.matches_with_bets_grouped_by_day(socket.assigns.user)
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
         matches_by_day: WorldCup.matches_with_bets_grouped_by_day(socket.assigns.user)
       )}
    end
  end

  defp format_day(%Date{} = day) do
    Calendar.strftime(
      day,
      "%d. %B",
      month_names: fn month ->
        {"januar", "februar", "mars", "april", "mai", "juni", "juli", "august", "september",
         "oktober", "november", "desember"}
        |> elem(month - 1)
      end
    )
  end
end

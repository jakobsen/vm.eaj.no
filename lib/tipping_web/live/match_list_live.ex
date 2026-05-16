defmodule TippingWeb.MatchListLive do
  use TippingWeb, :live_view

  import TippingWeb.MatchComponents

  alias Tipping.WorldCup

  @impl true

  def mount(_params, _session, socket) do
    matches_by_day =
      WorldCup.list_matches_with_bets(socket.assigns.user)
      |> Enum.map(fn entry ->
        %{
          entry
          | match: %{
              entry.match
              | kickoff_at: DateTime.shift_zone!(entry.match.kickoff_at, "Europe/Oslo")
            }
        }
      end)
      |> Enum.group_by(&DateTime.to_date(&1.match.kickoff_at))

    {:ok, assign(socket, matches_by_day: matches_by_day)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="p-5">
      <h1 class="font-bold text-4xl mb-5">Alle kamper</h1>
      <%= for {day, matches} <- Enum.sort_by(@matches_by_day, &elem(&1, 0), Date) do %>
        <h2 class="font-bold text-2xl mb-2.5">{format_day(day)}</h2>
        <div class="flex flex-col gap-8 max-w-lg mx-auto mb-10">
          <.match_card
            :for={entry <- matches}
            bet={entry.bet}
            match={entry.match}
          />
        </div>
      <% end %>
    </main>
    """
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

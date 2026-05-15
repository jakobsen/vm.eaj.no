defmodule TippingWeb.MatchListLive do
  use TippingWeb, :live_view

  import TippingWeb.MatchComponents

  alias Tipping.WorldCup

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, matches: WorldCup.list_matches())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="p-5">
      <h1 class="font-bold text-4xl mb-5">Alle kamper</h1>
      <div class="flex flex-col gap-8 max-w-lg mx-auto">
        <.match_card :for={match <- @matches} match={match} />
      </div>
    </main>
    """
  end
end

defmodule TippingWeb.MatchComponents do
  use TippingWeb, :verified_routes
  use Phoenix.Component

  alias Tipping.Game
  alias Tipping.WorldCup

  attr :date, Date, required: true

  def day_label(assigns) do
    [day_of_week, day_of_month, month] =
      Calendar.strftime(
        assigns.date,
        "%a.%d.%B",
        month_names: fn month ->
          {"januar", "februar", "mars", "april", "mai", "juni", "juli", "august", "september",
           "oktober", "november", "desember"}
          |> elem(month - 1)
        end,
        abbreviated_day_of_week_names: fn day ->
          {"man", "tir", "ons", "tor", "fre", "lør", "søn"} |> elem(day - 1)
        end
      )
      |> String.split(".")

    assigns =
      assigns
      |> assign(:day_of_week, day_of_week)
      |> assign(:day_of_month, day_of_month)
      |> assign(:month, month)

    ~H"""
    <h2 class="mx-auto -skew-x-20 -rotate-15 text-2xl mb-5 p-3 w-max bg-[#1C46D1]">
      {@day_of_week} <span class="font-extrabold">{@day_of_month}.</span> {@month}
    </h2>
    """
  end

  attr :bet, Game.Bet
  attr :match, WorldCup.Match

  def match_card(assigns) do
    ~H"""
    <div class="mb-15">
      <p class="p-2.5 mb-2.5 bg-dark-blue text-center tracking-[3%] leading-none text-lg">
        {format_kickoff_time(@match.kickoff_at)}
      </p>
      <form
        class="relative overflow-hidden bg-radial from-[#0099f7] to-[#093ca2] p-[3.24px] border border-[3.24px] border-white/10 rounded-[6.5px]"
        phx-change="place-bet"
        phx-auto-recover="recover-bet"
        phx-value-match_id={@match.id}
        phx-hook=".BetForm"
        id={"match-#{@match.id}-bet"}
      >
        <.decorative_circle />
        <div class="relative border border-[0.65px] border-white/50 rounded-[3.24px] p-6">
          <p class="absolute top-1.5 right-5 bg-dark-blue rounded-full text-sm px-2 py-1">
            {@match.stage}
          </p>

          <div class="flex justify-between">
            <.team_display team={@match.home_team} />
            <.bet_display bet={@bet} />
            <.team_display team={@match.away_team} />
          </div>
        </div>
      </form>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".BetForm">
      export default {
        mounted() {
          this.el.addEventListener("click", e => {
            const btn = e.target.closest("button[data-delta]");
            if (!btn) return;
            const target = btn.parentElement.querySelector("input");
            const delta = parseInt(btn.dataset.delta);
            const currentValue = parseInt(target.value);
            const isFirstInteraction = isNaN(currentValue);

            if (isFirstInteraction) {
              this.el.querySelectorAll("input").forEach(i => i.value = 0);
            } else {
              target.value = Math.max(0, currentValue + delta);
            }
            target.dispatchEvent(new Event("input", { bubbles: true }));
          })
        }
      }
    </script>
    """
  end

  defp decorative_circle(assigns) do
    ~H"""
    <div class="absolute left-1/2 top-1/2 -translate-1/2 border border-white/50 rounded-full size-[300px]" />
    """
  end

  attr :bet, Game.Bet

  defp bet_display(%{bet: nil} = assigns) do
    ~H"""
    <div class="text-2xl flex">
      <.bet_column side="home" /><.bet_column side="away" />
    </div>
    """
  end

  defp bet_display(assigns) do
    ~H"""
    <div class="text-2xl flex">
      <.bet_column score={@bet.home_score} side="home" />
      <.bet_column score={@bet.away_score} side="away" />
    </div>
    """
  end

  attr :score, :integer, default: nil
  attr :side, :string, values: ~w(home away), required: true

  defp bet_column(assigns) do
    assigns =
      assigns
      |> assign(:shared_classes, "block h-[2.5rem] w-[2.8rem]")
      |> assign(:button_classes, "font-light text-base cursor-pointer hover:bg-black/10")

    ~H"""
    <div class="grid grid-rows-3 border border-white last:border-l-0">
      <button class={[@shared_classes, @button_classes, "border-b"]} type="button" data-delta="1">
        +
      </button>
      <input
        name={@side}
        type="number"
        min="0"
        inputmode="numeric"
        readonly
        placeholder="–"
        value={@score}
        class={[
          @shared_classes,
          "text-center text-lg font-semibold border-b"
        ]}
      />
      <button class={[@shared_classes, @button_classes, "border-t-0"]} type="button" data-delta="-1">
        -
      </button>
    </div>
    """
  end

  attr :team, WorldCup.Team

  defp team_display(assigns) do
    ~H"""
    <div class="text-black rounded-xs bg-white/90 text-sm text-center p-2 mt-8 w-20 max-w-20 border border-black/5 team-card-shadow">
      <.flag team={@team} />
      <span class="inline-block mt-2">
        {get_in(@team.fifa_code) || "—"}
      </span>
    </div>
    """
  end

  attr :team, WorldCup.Team

  defp flag(%{team: nil} = assigns) do
    ~H"""
    <div class="mx-auto size-10 rounded text-white text-2xl font-semibold bg-gray-700 grid place-items-center">
      ?
    </div>
    """
  end

  defp flag(assigns) do
    ~H"""
    <img
      class="mx-auto size-10 rounded"
      src={static_path(TippingWeb.Endpoint, "/images/flags/#{@team.fifa_code}.svg")}
    />
    """
  end

  defp format_kickoff_time(%DateTime{} = kickoff) do
    kickoff |> DateTime.shift_zone!("Europe/Oslo") |> Calendar.strftime("%H:%M")
  end
end

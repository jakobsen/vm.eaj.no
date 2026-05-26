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
    <h2 class="mx-auto -skew-x-20 -rotate-15 text-2xl mb-15 p-3 w-max bg-[#1C46D1]">
      {@day_of_week} <span class="font-extrabold">{@day_of_month}.</span> {@month}
    </h2>
    """
  end

  attr :bet, Game.Bet
  attr :match, WorldCup.Match, required: true
  attr :locked?, :boolean, required: true

  def match_card(assigns) do
    status =
      cond do
        assigns.locked? -> :locked
        is_nil(assigns.match.home_team_id) or is_nil(assigns.match.away_team_id) -> :disabled
        true -> :open
      end

    gradient_colors =
      case status do
        :locked -> "from-[#1b3a35] to-[#1a4740]"
        :disabled -> "from-gray-500 to-gray-600"
        :open -> "from-[#0099f7] to-[#093ca2]"
      end

    assigns = assigns |> assign(:status, status) |> assign(:gradient_colors, gradient_colors)

    ~H"""
    <div class="mb-15">
      <p class="p-2.5 mb-2.5 bg-dark-blue text-center tracking-[3%] leading-none text-lg">
        {format_kickoff_time(@match.kickoff_at)}
      </p>
      <form
        class={[
          "relative overflow-hidden p-[3.24px] border border-[3.24px] border-white/10 rounded-[6.5px] bg-radial",
          @gradient_colors
        ]}
        phx-change="place-bet"
        phx-auto-recover="recover-bet"
        phx-value-match_id={@match.id}
        phx-hook=".BetForm"
        id={"match-#{@match.id}-bet"}
        disabled={@locked?}
      >
        <.decorative_circle />
        <div class="relative border border-[0.65px] border-white/50 rounded-[3.24px] p-3">
          <div class="grid grid-cols-3">
            <.team_display team={@match.home_team} />
            <.bet_display bet={@bet} status={@status} />
            <.team_display team={@match.away_team} />
          </div>
          <p class="absolute top-1.5 right-1.5 bg-dark-blue rounded-full text-sm font-light px-3 py-1 leading-none">
            <span class="inline-block translate-y-[-1.2px]">
              {@match.stage}
            </span>
          </p>
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
  attr :status, :atom, values: ~w(open locked disabled)a, required: true

  defp bet_display(assigns) do
    ~H"""
    <div class="justify-self-center">
      <p :if={@status == :locked} class="text-xs text-center small-caps font-light mb-2">Du tippet</p>
      <div class="text-2xl flex">
        <.bet_column score={get_in(@bet.home_score)} side="home" status={@status} />
        <.bet_column score={get_in(@bet.away_score)} side="away" status={@status} />
      </div>
    </div>
    """
  end

  attr :score, :integer, default: nil
  attr :side, :string, values: ~w(home away), required: true
  attr :status, :atom

  defp bet_column(%{status: :locked} = assigns) do
    ~H"""
    <div class="h-[2.5rem] w-[2.8rem] border text-center self-center last:border-l-0 text-lg font-semibold grid place-items-center">
      {@score || "–"}
    </div>
    """
  end

  defp bet_column(assigns) do
    assigns =
      assigns
      |> assign(:shared_classes, "block size-12")
      |> assign(:button_classes, [
        "font-light text-base touch-manipulation",
        assigns.status == :open && "hover:bg-white/10 active:bg-black/10 cursor-pointer"
      ])

    ~H"""
    <div class={[
      "grid border border-white last:border-l-0",
      @status == :disabled && "opacity-50"
    ]}>
      <button
        class={[@shared_classes, @button_classes, "border-b"]}
        type="button"
        data-delta="1"
        disabled={@status == :disabled}
      >
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
      <button
        class={[@shared_classes, @button_classes, "border-t-0"]}
        type="button"
        data-delta="-1"
        disabled={@status == :disabled}
      >
        -
      </button>
    </div>
    """
  end

  attr :team, WorldCup.Team

  defp team_display(assigns) do
    ~H"""
    <div class="text-black aspect-23/30 rounded-xs bg-white/90 text-sm text-center p-2 mt-8 w-23 border border-black/5 team-card-shadow last:justify-self-end">
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
    <div class="text-white text-2xl font-semibold bg-gray-700 grid place-items-center flag-shadow">
      ?
    </div>
    """
  end

  defp flag(assigns) do
    ~H"""
    <img
      class="flag-shadow"
      src={static_path(TippingWeb.Endpoint, "/images/flags/#{@team.fifa_code}.svg")}
    />
    """
  end

  defp format_kickoff_time(%DateTime{} = kickoff) do
    kickoff |> DateTime.shift_zone!("Europe/Oslo") |> Calendar.strftime("%H:%M")
  end
end

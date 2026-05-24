defmodule TippingWeb.PointsTableLive do
  use TippingWeb, :live_view

  import TippingWeb.PointsTableComponents

  alias Tipping.Game

  @impl true
  def mount(_params, _session, socket) do
    scores =
      socket.assigns.user
      |> Game.organization_scoreboard()
      |> prepare_table()

    all_alone? = match?([_], scores)

    {:ok,
     socket
     |> assign(:scores, scores)
     |> assign(:all_alone?, all_alone?)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_page={:tabell} flash={@flash}>
      <h1 class="large-heading mb-10">Tabell</h1>
      <p class="mb-3">Stillingen i {@user.organization} så langt.</p>
      <.scoreboard scores={@scores} />
      <div :if={@all_alone?} class="mt-10">
        <p class="mb-5">
          Litt ensomt her? Hvorfor ikke dele lenken med noen kollegaer, fiender eller venner?
        </p>
        <button
          class="mx-auto p-2 w-38 flex justify-center items-baseline gap-2 rounded border hover:bg-white/10 action:bg-black/10"
          id="copy-link"
          data-clipboard-text={url(~p"/")}
        >
          Kopier lenke <.icon name="hero-document-duplicate" />
        </button>
      </div>
    </Layouts.app>
    <script>
      const copyButton = document.querySelector("#copy-link");
      const originalHtml = copyButton.innerHTML;

      copyButton.addEventListener("click", () => {
        navigator.clipboard.writeText(copyButton.dataset.clipboardText).then(() => {
          copyButton.innerText = "Kopiert!";
          setTimeout(() => {
            copyButton.innerHTML = originalHtml;
          }, 2000);
        });
      });
    </script>
    """
  end

  @doc """
  Adds a position attribute to a list of maps containing a points attribute.
  The maps are expected to be sorted in descending order by points.
  Handles ties.
  """
  def prepare_table([]), do: []

  def prepare_table(scores) do
    {updated_scores, _acc} =
      scores
      |> Enum.with_index(1)
      |> Enum.map_reduce(%{points: :infinity}, fn {row, idx}, prev_row ->
        position = if row.points == prev_row.points, do: prev_row.position, else: idx

        updated_row =
          row
          |> Map.put(:position, position)
          |> Map.put(:name, row.user.name)
          |> Map.delete(:user)

        {updated_row, updated_row}
      end)

    updated_scores
  end
end

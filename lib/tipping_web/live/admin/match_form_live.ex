defmodule TippingWeb.Admin.MatchFormLive do
  use TippingWeb, :live_view

  alias Tipping.WorldCup

  def mount(%{"id" => id}, _session, socket) do
    match = WorldCup.get_match(id, [:home_team, :away_team])
    team_options = WorldCup.list_teams() |> Enum.map(fn %{id: id, name: name} -> {name, id} end)

    {:ok,
     socket
     |> assign(:match, match)
     |> assign(:team_options, team_options)
     |> assign(:form, to_form(WorldCup.change_match(match)))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {get_in(@match.home_team.name) || "TBD"}–{get_in(@match.away_team.name) || "TBD"}
        <:subtitle>
          {@match.kickoff_at
          |> DateTime.shift_zone!("Europe/Oslo")
          |> Calendar.strftime("%-d. %b kl. %H:%M")}
        </:subtitle>
      </.header>

      <.form for={@form} id="match-form" phx-change="validate" phx-submit="save">
        <div class="grid grid-cols-2 gap-2">
          <.input
            label="Hjemmelag"
            field={@form[:home_team_id]}
            type="select"
            options={@team_options}
          />
          <.input label="Bortelag" field={@form[:away_team_id]} type="select" options={@team_options} />
          <.input label="Mål hjemme" type="number" field={@form[:home_score]} min="0" />
          <.input label="Mål borte" type="number" field={@form[:away_score]} min="0" />
        </div>

        <footer>
          <.button phx-disable-with="Lagrer..." variant="primary">Oppdater kamp</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  def handle_event("validate", %{"match" => match_params}, socket) do
    changeset = WorldCup.change_match(socket.assigns.match, match_params)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"match" => match_params}, socket) do
    case WorldCup.update_match(socket.assigns.user, socket.assigns.match, match_params) do
      {:ok, _match} ->
        {:noreply,
         socket |> put_flash(:info, "Kampen er oppdatert") |> push_navigate(to: ~p"/admin")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, inspect(changeset.errors))
         |> assign(:form, to_form(changeset))}
    end
  end
end

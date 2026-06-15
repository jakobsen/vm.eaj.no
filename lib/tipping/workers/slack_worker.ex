defmodule Tipping.Workers.SlackWorker do
  @moduledoc """
  Worker for sending the scoreboard to Slack.
  """

  use Oban.Worker

  alias Tipping.Game
  alias Tipping.Slack

  @impl true
  def perform(_job) do
    standings = get_scoreboard("aidn.no")
    channel = get_channel!()
    token = get_token!()

    Slack.random_greeting()
    |> Slack.format_message(standings)
    |> Slack.send_message(channel, token)
  end

  defp get_scoreboard(organization) do
    Game.organization_scoreboard(organization)
    |> Enum.map(&Map.put(&1, :name, &1.user.name))
  end

  defp get_channel!() do
    Application.fetch_env!(:tipping, __MODULE__) |> Keyword.fetch!(:channel)
  end

  defp get_token!() do
    Application.fetch_env!(:tipping, __MODULE__) |> Keyword.fetch!(:token)
  end
end

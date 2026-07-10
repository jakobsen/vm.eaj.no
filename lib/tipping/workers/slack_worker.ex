defmodule Tipping.Workers.SlackWorker do
  @moduledoc """
  Worker for sending the scoreboard to Slack.
  """

  use Oban.Worker

  alias Tipping.Game
  alias Tipping.Slack
  alias Tipping.WorldCup

  @impl true
  def perform(_job) do
    now = DateTime.utc_now()
    yesterday = DateTime.add(now, -1, :day)
    send_latest_standings? = WorldCup.count_matches_in_timespan(yesterday, now) > 0

    if send_latest_standings? do
      send_message(now)
    else
      {:cancel, "No relevant matches"}
    end
  end

  def send_message(now \\ DateTime.utc_now()) do
    standings = get_standings(now)
    channel = get_channel!()
    token = get_token!()

    Slack.random_greeting()
    |> Slack.format_message(standings)
    |> Slack.send_message(channel, token)
  end

  def get_standings(now \\ DateTime.utc_now()) do
    yesterday = DateTime.add(now, -1, :day)

    yesterdays_standings =
      Game.organization_scoreboard("aidn.no", include_matches_until: yesterday)
      |> Enum.map(&{&1.user.id, &1})
      |> Map.new()

    Game.organization_scoreboard("aidn.no", include_matches_until: now)
    |> Enum.map(fn row ->
      row
      |> Map.put(:previous_position, yesterdays_standings[row.user.id][:position])
      |> Map.put(:previous_points, yesterdays_standings[row.user.id][:points])
      |> Map.put(:name, row.user.name)
    end)
  end

  defp get_channel!() do
    Application.fetch_env!(:tipping, __MODULE__) |> Keyword.fetch!(:channel)
  end

  defp get_token!() do
    Application.fetch_env!(:tipping, __MODULE__) |> Keyword.fetch!(:token)
  end
end

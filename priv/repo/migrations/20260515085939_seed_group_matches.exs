defmodule Tipping.Repo.Migrations.SeedGroupMatches do
  use Ecto.Migration
  import Ecto.Query

  def up do
    now = DateTime.utc_now(:second)
    teams = repo().all(from(t in "teams", select: {t.fifa_code, t.id})) |> Map.new()
    matches = get_matches()

    rows =
      Enum.map(matches, fn match ->
        Map.merge(match, %{
          home_team_id: match.home_team && Map.fetch!(teams, match.home_team),
          away_team_id: match.away_team && Map.fetch!(teams, match.away_team),
          inserted_at: now,
          updated_at: now
        })
        |> Map.drop([:home_team, :away_team])
      end)

    repo().insert_all("matches", rows)
  end

  def down do
    repo().delete_all("matches")
  end

  # Data from https://github.com/openfootball/worldcup.json/blob/752a1137a20810ab37473fa9f87a9c2caf293785/2026/worldcup.json
  defp get_matches() do
    teams_path = Application.app_dir(:tipping, "priv/repo/data/teams.json")
    matches_path = Application.app_dir(:tipping, "priv/repo/data/matches.json")
    %{"matches" => matches} = matches_path |> File.read!() |> JSON.decode!()

    teams =
      teams_path
      |> File.read!()
      |> JSON.decode!()
      |> Enum.map(&{&1["name"], &1["fifa_code"]})
      |> Map.new()

    Enum.map(matches, fn match ->
      %{
        home_team: Map.get(teams, match["team1"]),
        away_team: Map.get(teams, match["team2"]),
        kickoff_at: parse_kickoff(match),
        stage: parse_stage(match)
      }
    end)
  end

  defp parse_kickoff(%{"date" => date, "time" => time}) do
    [clock_time, "UTC" <> offset_str] = String.split(time, " ", parts: 2)
    offset = String.to_integer(offset_str)

    NaiveDateTime.from_iso8601!("#{date}T#{clock_time}:00")
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.add(-offset, :hour)
  end

  defp parse_stage(%{"round" => "Matchday" <> _, "group" => "Group " <> group}),
    do: "Gruppe " <> group

  defp parse_stage(%{"round" => "Round of 32"}), do: "Sekstendelsfinale"
  defp parse_stage(%{"round" => "Round of 16"}), do: "Åttedelsfinale"
  defp parse_stage(%{"round" => "Quarter-final"}), do: "Kvartfinale"
  defp parse_stage(%{"round" => "Semi-final"}), do: "Semifinale"
  defp parse_stage(%{"round" => "Match for third place"}), do: "Bronsefinale"
  defp parse_stage(%{"round" => "Final"}), do: "Finale"
end

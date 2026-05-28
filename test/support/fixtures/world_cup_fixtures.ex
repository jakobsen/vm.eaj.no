defmodule Tipping.WorldCupFixtures do
  @moduledoc false

  alias Tipping.WorldCup
  alias Tipping.Repo

  def match_fixture(attrs \\ %{}) do
    params = attrs |> valid_match_attributes()
    {:ok, match} = struct(WorldCup.Match, params) |> Repo.insert()
    match
  end

  defp valid_match_attributes(attrs) do
    [home_team, away_team | _] = Repo.all(WorldCup.Team) |> Enum.shuffle()

    Enum.into(attrs, %{
      kickoff_at: ~U[2026-06-11 19:00:00Z],
      home_team_id: home_team.id,
      away_team_id: away_team.id,
      stage: "Gruppe A"
    })
  end
end

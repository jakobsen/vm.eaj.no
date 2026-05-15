defmodule Tipping.WorldCupTest do
  use Tipping.DataCase

  alias Tipping.WorldCup
  alias Tipping.Repo

  test "every team has a flag" do
    teams = Repo.all(WorldCup.Team)

    for team <- teams do
      flag_path = Application.app_dir(:tipping, "priv/static/images/flags/#{team.fifa_code}.svg")
      assert File.exists?(flag_path), "No flag found for #{team.name} (#{team.fifa_code})"
    end
  end

  describe "list_matches/0" do
    test "matches are sorted by kickoff time" do
      matches = WorldCup.list_matches() |> Enum.map(&Map.take(&1, [:id, :kickoff_at]))
      sorted = Enum.sort_by(matches, & &1.kickoff_at, DateTime)
      assert matches == sorted
    end
  end
end

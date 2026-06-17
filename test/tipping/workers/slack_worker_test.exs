defmodule Tipping.Workers.SlackWorkerTest do
  use Tipping.DataCase

  import Tipping.AccountsFixtures
  import Tipping.WorldCupFixtures

  alias Tipping.Game
  alias Tipping.Workers.SlackWorker

  describe "get_standings/1" do
    test "correctly calculates diff in position from yesterday" do
      today = ~U[2026-06-17 12:00:00Z]
      last_night = DateTime.add(today, -12, :hour)
      last_week = DateTime.add(today, -8, :day)

      last_weeks_match = match_fixture(%{home_score: 1, away_score: 2, kickoff_at: last_week})
      last_nights_match = match_fixture(%{home_score: 0, away_score: 0, kickoff_at: last_night})
      yesterdays_winner = user_fixture(organization: "aidn.no", name: "Jim")
      todays_winner = user_fixture(organization: "aidn.no", name: "Michael")

      # 2 points on last week's game
      Game.place_bet(
        yesterdays_winner,
        last_weeks_match,
        %{home_score: 2, away_score: 3},
        DateTime.add(last_weeks_match.kickoff_at, -11, :minute)
      )

      # 3 points on last night's game
      Game.place_bet(
        todays_winner,
        last_nights_match,
        %{home_score: 0, away_score: 0},
        DateTime.add(last_nights_match.kickoff_at, -11, :minute)
      )

      assert [
               %{
                 name: "Michael",
                 points: 3,
                 previous_points: 0,
                 position: 1,
                 previous_position: 2
               },
               %{name: "Jim", points: 2, previous_points: 2, position: 2, previous_position: 1}
             ] =
               SlackWorker.get_standings(today)
    end
  end
end

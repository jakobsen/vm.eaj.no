defmodule TippingWeb.MatchListLiveTest do
  use TippingWeb.ConnCase

  import Tipping.AccountsFixtures

  alias Tipping.WorldCup.Match
  alias Tipping.WorldCup
  alias TippingWeb.MatchListLive

  describe "matches_with_bets_grouped_by_day/1" do
    setup do
      %{user: user_fixture()}
    end

    test "returns a list of tuples where the first element is a date and the second element is a list of matches and bets",
         %{user: user} do
      entries = MatchListLive.matches_with_bets_grouped_by_day(user)

      assert match?(
               %{matches_by_day: [{%Date{}, [%{match: %WorldCup.Match{}, bet: _} | _]} | _]},
               entries
             )
    end

    test "the dates are in sorted order", %{user: user} do
      %{matches_by_day: entries} = MatchListLive.matches_with_bets_grouped_by_day(user)
      sorted_entries = Enum.sort_by(entries, &elem(&1, 0), Date)
      assert entries == sorted_entries
    end

    test "the matches' kickoff time is listed in the Europe/Oslo time zone", %{user: user} do
      matches =
        MatchListLive.matches_with_bets_grouped_by_day(user)
        |> Map.get(:matches_by_day)
        |> Enum.flat_map(fn {_date, matches} -> matches end)
        |> Enum.map(& &1.match)

      assert Enum.all?(matches, fn match -> match.kickoff_at.time_zone == "Europe/Oslo" end)
    end
  end

  describe "match_status/2" do
    test "A match with unknown team IDs is disabled" do
      assert MatchListLive.match_status(
               %Match{},
               ~U[2026-06-01 21:00:00Z]
             ) == :disabled
    end

    test "A match ocurring more than 10 minutes in the future is open" do
      assert MatchListLive.match_status(
               %Match{kickoff_at: ~U[2026-06-11 19:00:00Z], home_team_id: 1, away_team_id: 2},
               ~U[2026-06-01 21:00:00Z]
             ) == :open
    end
  end

  test "A match ocurring 10 minutes and 1 second in the future is open" do
    assert MatchListLive.match_status(
             %Match{kickoff_at: ~U[2026-06-11 19:00:00Z], home_team_id: 1, away_team_id: 2},
             ~U[2026-06-11 18:49:59Z]
           ) == :open
  end

  test "A match ocurring exactly 10 minutes in the future is locked" do
    assert MatchListLive.match_status(
             %Match{kickoff_at: ~U[2026-06-11 19:00:00Z], home_team_id: 1, away_team_id: 2},
             ~U[2026-06-11 18:50:00Z]
           ) == :locked
  end

  test "A match ocurring in the past with no score set is locked" do
    assert MatchListLive.match_status(
             %Match{kickoff_at: ~U[2026-06-11 19:00:00Z], home_team_id: 1, away_team_id: 2},
             ~U[2026-06-11 20:50:00Z]
           ) == :locked
  end

  test "A match with a score set is complete" do
    assert MatchListLive.match_status(
             %Match{
               home_score: Enum.random(0..10),
               away_score: Enum.random(0..10),
               home_team_id: 1,
               away_team_id: 2
             },
             ~U[2026-06-11 20:50:00Z]
           ) == :complete
  end
end

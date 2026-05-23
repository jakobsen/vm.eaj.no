defmodule TippingWeb.MatchListLiveTest do
  use TippingWeb.ConnCase

  import Tipping.AccountsFixtures

  alias Tipping.WorldCup
  alias TippingWeb.MatchListLive

  describe "matches_with_bets_grouped_by_day/1" do
    setup do
      %{user: user_fixture()}
    end

    test "returns a list of tuples where the first element is a date and the second element is a list of matches and bets",
         %{user: user} do
      entries = MatchListLive.matches_with_bets_grouped_by_day(user)
      assert match?([{%Date{}, [%{match: %WorldCup.Match{}, bet: _} | _]} | _], entries)
    end

    test "the dates are in sorted order", %{user: user} do
      entries = MatchListLive.matches_with_bets_grouped_by_day(user)
      sorted_entries = Enum.sort_by(entries, &elem(&1, 0), Date)
      assert entries == sorted_entries
    end

    test "the matches' kickoff time is listed in the Europe/Oslo time zone", %{user: user} do
      matches =
        MatchListLive.matches_with_bets_grouped_by_day(user)
        |> Enum.flat_map(fn {_date, matches} -> matches end)
        |> Enum.map(& &1.match)

      assert Enum.all?(matches, fn match -> match.kickoff_at.time_zone == "Europe/Oslo" end)
    end
  end
end

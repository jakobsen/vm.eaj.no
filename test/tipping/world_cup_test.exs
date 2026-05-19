defmodule Tipping.WorldCupTest do
  use Tipping.DataCase

  import Ecto.Query
  import Tipping.AccountsFixtures

  alias Tipping.Game
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

  describe "list_matches_with_bets/1" do
    setup do
      %{user: user_fixture(), match: Repo.one(from m in WorldCup.Match, limit: 1)}
    end

    test "a user's bets are included", %{user: user, match: match} do
      {:ok, bet} = Game.place_bet(user, match, %{home_score: 3, away_score: 2})

      matches_with_bets = WorldCup.list_matches_with_bets(user)
      assert match_with_bet = Enum.find(matches_with_bets, &(&1.match.id == match.id))
      assert match_with_bet.bet.id == bet.id
    end

    test "users can only see their own bets", %{user: user, match: match} do
      another_user = user_fixture()
      {:ok, bet} = Game.place_bet(user, match, %{home_score: 3, away_score: 2})
      {:ok, another_bet} = Game.place_bet(another_user, match, %{home_score: 2, away_score: 0})

      matches_with_bets = WorldCup.list_matches_with_bets(user)
      assert match_with_bet = Enum.find(matches_with_bets, &(&1.match.id == match.id))
      assert match_with_bet.bet.id == bet.id
      refute Enum.find(matches_with_bets, &(get_in(&1.bet.id) == another_bet.id))
    end

    test "If no bets are made, the bet lists as nil", %{user: user} do
      matches_with_bets = WorldCup.list_matches_with_bets(user)
      assert Enum.all?(matches_with_bets, &is_nil(&1.bet))
    end
  end

  describe "matches_with_bets_grouped_by_day/1" do
    setup do
      %{user: user_fixture()}
    end

    test "returns a list of tuples where the first element is a date and the second element is a list of matches and bets",
         %{user: user} do
      entries = WorldCup.matches_with_bets_grouped_by_day(user)
      assert match?([{%Date{}, [%{match: %WorldCup.Match{}, bet: _} | _]} | _], entries)
    end

    test "the dates are in sorted order", %{user: user} do
      entries = WorldCup.matches_with_bets_grouped_by_day(user)
      sorted_entries = Enum.sort_by(entries, &elem(&1, 0), Date)
      assert entries == sorted_entries
    end
  end

  describe "update_match/3" do
    setup do
      %{
        user: user_fixture(),
        admin_user: admin_user_fixture(),
        match: Repo.one(from m in WorldCup.Match, limit: 1)
      }
    end

    test "trying to update a match with a non-admin raises", %{user: user, match: match} do
      assert_raise(FunctionClauseError, fn -> WorldCup.update_match(user, match, %{}) end)
    end

    test "an admin user can update a match", %{admin_user: user, match: match} do
      home_score = Enum.random(0..9)
      away_score = Enum.random(0..9)
      [home_team, away_team | _] = Repo.all(WorldCup.Team) |> Enum.shuffle()

      assert {:ok, updated_match} =
               WorldCup.update_match(user, match, %{
                 home_score: home_score,
                 away_score: away_score,
                 home_team_id: home_team.id,
                 away_team_id: away_team.id
               })

      assert updated_match.home_score == home_score
      assert updated_match.away_score == away_score
      assert updated_match.home_team_id == home_team.id
      assert updated_match.away_team_id == away_team.id
    end

    test "setting only one score returns an error", %{admin_user: user, match: match} do
      assert {:error, %Ecto.Changeset{}} = WorldCup.update_match(user, match, %{home_score: 0})
    end

    test "it is possible to set only the score", %{admin_user: user, match: match} do
      home_score = Enum.random(0..9)
      away_score = Enum.random(0..9)

      assert {:ok, _match} =
               WorldCup.update_match(user, match, %{
                 home_score: home_score,
                 away_score: away_score
               })
    end
  end
end

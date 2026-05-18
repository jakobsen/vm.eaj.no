defmodule Tipping.GameTest do
  use Tipping.DataCase

  import Ecto.Query
  import Tipping.AccountsFixtures

  alias Tipping.Game
  alias Tipping.WorldCup

  setup do
    user = user_fixture()
    match = Repo.one(from m in WorldCup.Match, limit: 1)

    %{user: user, match: match}
  end

  describe "place_bet/3" do
    test "a user can place a bet", %{user: user, match: match} do
      assert {:ok, bet} = Game.place_bet(user, match, %{home_score: 2, away_score: 1})
      assert bet.user_id == user.id
      assert bet.match_id == match.id
      assert bet.home_score == 2
      assert bet.away_score == 1
    end

    test "placing a second bet updates the first", %{user: user, match: match} do
      {:ok, first_bet} = Game.place_bet(user, match, %{home_score: 1, away_score: 0})
      assert {:ok, second_bet} = Game.place_bet(user, match, %{home_score: 1, away_score: 2})
      assert first_bet.id == second_bet.id
      assert second_bet.home_score == 1
      assert second_bet.away_score == 2
    end

    test "a bet cannot contain negative goals", %{user: user, match: match} do
      assert {:error, _} = Game.place_bet(user, match, %{home_score: -1, away_score: 0})
      assert {:error, _} = Game.place_bet(user, match, %{home_score: 0, away_score: -1})
    end

    test "missing scores default to 0", %{user: user, match: match} do
      assert {:ok, bet} = Game.place_bet(user, match, %{})
      assert bet.home_score == 0
      assert bet.away_score == 0
    end
  end
end

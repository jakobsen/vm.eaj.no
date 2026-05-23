defmodule Tipping.GameTest do
  alias Tipping.WorldCup
  use Tipping.DataCase

  import Tipping.AccountsFixtures

  alias Tipping.Repo
  alias Tipping.Game
  alias Tipping.Game.Bet
  alias Tipping.WorldCup.Match

  describe "place_bet/3" do
    setup do
      user = user_fixture()

      [home_team, away_team] = WorldCup.list_teams() |> Enum.take(2)

      match =
        %Match{
          kickoff_at: ~U[2026-06-11 19:00:00Z],
          stage: "Gruppe A",
          home_team_id: home_team.id,
          away_team_id: away_team.id
        }
        |> Repo.insert!()

      %{
        user: user,
        match: match,
        half_hour_before_kickoff: ~U[2026-06-11 18:30:00Z],
        half_hour_after_kickoff: ~U[2026-06-11 19:30:00Z]
      }
    end

    test "a user can place a bet", %{
      user: user,
      match: match,
      half_hour_before_kickoff: half_hour_before_kickoff
    } do
      assert {:ok, bet} =
               Game.place_bet(
                 user,
                 match,
                 %{home_score: 2, away_score: 1},
                 half_hour_before_kickoff
               )

      assert bet.user_id == user.id
      assert bet.match_id == match.id
      assert bet.home_score == 2
      assert bet.away_score == 1
    end

    test "placing a second bet updates the first", %{
      user: user,
      match: match,
      half_hour_before_kickoff: half_hour_before_kickoff
    } do
      {:ok, first_bet} =
        Game.place_bet(user, match, %{home_score: 1, away_score: 0}, half_hour_before_kickoff)

      assert {:ok, second_bet} =
               Game.place_bet(
                 user,
                 match,
                 %{home_score: 1, away_score: 2},
                 half_hour_before_kickoff
               )

      assert first_bet.id == second_bet.id
      assert second_bet.home_score == 1
      assert second_bet.away_score == 2
    end

    test "a bet cannot contain negative goals", %{
      user: user,
      match: match,
      half_hour_before_kickoff: half_hour_before_kickoff
    } do
      assert {:error, _} =
               Game.place_bet(
                 user,
                 match,
                 %{home_score: -1, away_score: 0},
                 half_hour_before_kickoff
               )

      assert {:error, _} =
               Game.place_bet(
                 user,
                 match,
                 %{home_score: 0, away_score: -1},
                 half_hour_before_kickoff
               )
    end

    test "missing scores default to 0", %{
      user: user,
      match: match,
      half_hour_before_kickoff: half_hour_before_kickoff
    } do
      assert {:ok, bet} = Game.place_bet(user, match, %{}, half_hour_before_kickoff)
      assert bet.home_score == 0
      assert bet.away_score == 0
    end

    test "a bet cannot be placed after kickoff", %{
      user: user,
      match: match,
      half_hour_after_kickoff: half_hour_after_kickoff
    } do
      assert {:error, :match_locked} =
               Game.place_bet(
                 user,
                 match,
                 %{home_score: 1, away_score: 2},
                 half_hour_after_kickoff
               )
    end
  end

  describe "match_locked?/2" do
    test "a match with kickoff more than 10 minutes in the future is not locked" do
      match = %Match{kickoff_at: ~U[2026-06-11 19:00:00Z]}
      now = ~U[2026-06-11 18:30:00Z]
      refute Game.match_locked?(match, now)
    end

    test "a match with kickoff exactly 10 minutes in the future is locked" do
      match = %Match{kickoff_at: ~U[2026-06-12 20:00:00Z]}
      now = ~U[2026-06-12 19:50:00Z]
      assert Game.match_locked?(match, now)
    end

    test "a match with kickoff time in the past is locked" do
      match = %Match{kickoff_at: ~U[2026-07-01 15:00:00Z]}
      now = ~U[2026-07-02 00:00:00Z]
      assert Game.match_locked?(match, now)
    end
  end

  describe "bet_score/2" do
    test "An unfinished match is worth 0 points" do
      home_score = Enum.random(0..10)
      away_score = Enum.random(0..10)

      points =
        Game.bet_points(
          %Bet{home_score: home_score, away_score: away_score},
          %Match{}
        )

      assert points == 0
    end

    test "A bet predicting the exact score is worth 3 points" do
      home_score = Enum.random(0..10)
      away_score = Enum.random(0..10)

      points =
        Game.bet_points(
          %Bet{home_score: home_score, away_score: away_score},
          %Match{
            home_score: home_score,
            away_score: away_score
          }
        )

      assert points == 3
    end

    test "A bet predicting a tie exactly right is worth 3 points" do
      score = Enum.random(1..10)

      points =
        Game.bet_points(
          %Bet{home_score: score, away_score: score},
          %Match{
            home_score: score,
            away_score: score
          }
        )

      assert points == 3
    end

    test "A bet correctly predicting a tie with an offset is worth 2 points" do
      match_score = Enum.random(0..3)
      bet_score = match_score + Enum.random(1..4)

      points =
        Game.bet_points(
          %Bet{home_score: bet_score, away_score: bet_score},
          %Match{
            home_score: match_score,
            away_score: match_score
          }
        )

      assert points == 2
    end

    test "A bet predicting the correct goal difference is worth 2 points" do
      losing_score = Enum.random(0..5)
      winning_score = losing_score + Enum.random(1..4)
      bet_offset = Enum.random(1..3)

      # home wins
      assert Game.bet_points(
               %Bet{
                 home_score: winning_score + bet_offset,
                 away_score: losing_score + bet_offset
               },
               %Match{
                 home_score: winning_score,
                 away_score: losing_score
               }
             ) == 2

      # away wins
      assert Game.bet_points(
               %Bet{
                 home_score: losing_score + bet_offset,
                 away_score: winning_score + bet_offset
               },
               %Match{
                 home_score: losing_score,
                 away_score: winning_score
               }
             ) == 2
    end

    test "A bet predicting the correct winner, but not the correct score or GD, is worth 1 point" do
      losing_score = Enum.random(0..5)
      winning_score = losing_score + Enum.random(1..4)
      bet_offset = Enum.random(1..7)

      # home wins
      assert Game.bet_points(
               %Bet{
                 home_score: winning_score + bet_offset,
                 away_score: losing_score
               },
               %Match{
                 home_score: winning_score,
                 away_score: losing_score
               }
             ) == 1

      # away wins
      assert Game.bet_points(
               %Bet{
                 home_score: losing_score,
                 away_score: winning_score + bet_offset
               },
               %Match{
                 home_score: losing_score,
                 away_score: winning_score
               }
             ) == 1
    end

    test "A bet which misses all of the above is worth 0 points" do
      losing_score = Enum.random(0..5)
      winning_score = losing_score + Enum.random(1..4)
      bet_offset = Enum.random(0..5)

      # Incorrectly betted on a home win
      assert Game.bet_points(
               %Bet{home_score: winning_score + bet_offset, away_score: losing_score},
               %Match{
                 home_score: losing_score,
                 away_score: winning_score
               }
             ) == 0

      # Incorrectly betted on an away win, actually a tie
      assert Game.bet_points(
               %Bet{home_score: losing_score, away_score: winning_score},
               %Match{home_score: winning_score, away_score: winning_score}
             ) == 0

      # Incorrectly betted on a tie, home win
      assert Game.bet_points(
               %Bet{home_score: winning_score, away_score: winning_score},
               %Match{home_score: winning_score, away_score: losing_score}
             ) == 0
    end
  end
end

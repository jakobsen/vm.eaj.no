defmodule Tipping.Game do
  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.Repo
  alias Tipping.WorldCup

  def place_bet(
        %Accounts.User{} = user,
        %WorldCup.Match{} = match,
        params,
        now \\ DateTime.utc_now()
      ) do
    if match_locked?(match, now) do
      {:error, :match_locked}
    else
      %Game.Bet{user_id: user.id, match_id: match.id}
      |> Game.Bet.changeset(params)
      |> Repo.insert(
        on_conflict: {:replace, [:home_score, :away_score, :updated_at]},
        conflict_target: [:user_id, :match_id]
      )
    end
  end

  def match_locked?(%WorldCup.Match{} = match, now \\ DateTime.utc_now()) do
    DateTime.diff(match.kickoff_at, now, :second) <= 600
  end

  def bet_points(%Game.Bet{} = bet, %WorldCup.Match{} = match) do
    cond do
      empty_scores?(match) -> 0
      empty_scores?(bet) -> 0
      exact_score?(bet, match) -> 3
      correct_goal_difference?(bet, match) -> 2
      correct_winner?(bet, match) -> 1
      true -> 0
    end
  end

  defp empty_scores?(%{home_score: home_score, away_score: away_score}),
    do: is_nil(home_score) or is_nil(away_score)

  defp exact_score?(bet, match),
    do: bet.home_score == match.home_score and bet.away_score == match.away_score

  defp correct_goal_difference?(bet, match),
    do: bet.home_score - bet.away_score == match.home_score - match.away_score

  defp correct_winner?(bet, match),
    do:
      (bet.home_score > bet.away_score and match.home_score > match.away_score) or
        (bet.home_score < bet.away_score and match.home_score < match.away_score)
end

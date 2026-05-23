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
end

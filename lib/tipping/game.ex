defmodule Tipping.Game do
  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.Repo
  alias Tipping.WorldCup

  def place_bet(%Accounts.User{} = user, %WorldCup.Match{} = match, params) do
    %Game.Bet{user_id: user.id, match_id: match.id}
    |> Game.Bet.changeset(params)
    |> Repo.insert(
      on_conflict: {:replace, [:home_score, :away_score, :updated_at]},
      conflict_target: [:user_id, :match_id]
    )
  end
end

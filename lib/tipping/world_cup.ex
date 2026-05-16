defmodule Tipping.WorldCup do
  import Ecto.Query

  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.Repo
  alias Tipping.WorldCup

  def list_matches(),
    do:
      Repo.all(
        from m in WorldCup.Match,
          order_by: :kickoff_at,
          preload: [:home_team, :away_team]
      )

  def list_matches_with_bets(%Accounts.User{} = user) do
    Repo.all(
      from m in WorldCup.Match,
        left_join: b in Game.Bet,
        on: b.match_id == m.id and b.user_id == ^user.id,
        order_by: :kickoff_at,
        preload: [:home_team, :away_team],
        select: %{match: m, bet: b}
    )
  end
end

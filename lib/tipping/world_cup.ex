defmodule Tipping.WorldCup do
  import Ecto.Query

  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.Repo
  alias Tipping.WorldCup

  def get_match(id), do: Repo.get(WorldCup.Match, id)

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

  def matches_with_bets_grouped_by_day(%Accounts.User{} = user) do
    list_matches_with_bets(user)
    |> Enum.map(fn entry ->
      match = entry.match

      %{
        entry
        | match: %{match | kickoff_at: DateTime.shift_zone!(match.kickoff_at, "Europe/Oslo")}
      }
    end)
    |> Enum.group_by(&DateTime.to_date(&1.match.kickoff_at))
    |> Map.to_list()
    |> Enum.sort_by(fn {date, _} -> date end, Date)
  end
end

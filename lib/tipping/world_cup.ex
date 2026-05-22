defmodule Tipping.WorldCup do
  import Ecto.Query

  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.Repo
  alias Tipping.WorldCup

  def get_match(id, preloads \\ []), do: Repo.get(WorldCup.Match, id) |> Repo.preload(preloads)

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

  def list_teams(), do: Repo.all(from t in WorldCup.Team, order_by: t.name)

  def matches_with_bets_grouped_by_day(%Accounts.User{} = user) do
    list_matches_with_bets(user)
    |> Enum.map(fn entry ->
      update_in(entry.match.kickoff_at, &DateTime.shift_zone!(&1, "Europe/Oslo"))
    end)
    |> Enum.group_by(&DateTime.to_date(&1.match.kickoff_at))
    |> Map.to_list()
    |> Enum.sort_by(fn {date, _} -> date end, Date)
  end

  def update_match(%Accounts.User{admin?: true}, %WorldCup.Match{} = match, attrs) do
    match
    |> WorldCup.Match.changeset(attrs)
    |> Repo.update()
  end

  def change_match(%WorldCup.Match{} = match, attrs \\ %{}) do
    WorldCup.Match.changeset(match, attrs)
  end
end

defmodule Tipping.Game do
  @moduledoc """
  Context concerned with bets and user points.
  """

  import Ecto.Query

  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.Repo
  alias Tipping.WorldCup

  @kernel_orgs ["aidn.no", "deepinsight.io"]

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

  @doc """
  Get the scoreboard for an organization.

  ## Options
    * `:include_matches_until` (DateTime). Only include matches with kickoff before
      the given DateTime. Defaults to DateTime.utc_now().
  """
  def organization_scoreboard(organization, opts \\ []) when is_binary(organization) do
    include_matches_until = Keyword.get(opts, :include_matches_until, DateTime.utc_now())

    matches =
      Repo.all(
        from m in WorldCup.Match,
          where:
            m.kickoff_at <= ^include_matches_until and
              not is_nil(m.home_score) and
              not is_nil(m.away_score)
      )
      |> Map.new(&{&1.id, &1})

    users = users_in_org_query(organization, Map.keys(matches)) |> Repo.all()

    {points_table, _last_row} =
      users
      |> Enum.map(fn u ->
        total_points = Enum.sum_by(u.bets, &bet_points(&1, Map.fetch!(matches, &1.match_id)))
        %{user: u, points: total_points}
      end)
      |> Enum.sort_by(&{-&1.points, &1.user.name})
      |> Enum.with_index(1)
      |> Enum.map_reduce(%{points: :infinity}, fn {row, idx}, prev_row ->
        position = if row.points == prev_row.points, do: prev_row.position, else: idx

        updated_row = Map.put(row, :position, position)

        {updated_row, updated_row}
      end)

    points_table
  end

  def bet_points(nil = _bet, %WorldCup.Match{}), do: nil

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

  defp users_in_org_query(organization, bet_match_ids)
       when organization in @kernel_orgs do
    bets_query = from(b in Game.Bet, where: b.match_id in ^bet_match_ids)

    from(u in Accounts.User,
      where: u.organization in @kernel_orgs,
      preload: [bets: ^bets_query]
    )
  end

  defp users_in_org_query(organization, bet_match_ids) do
    bets_query = from(b in Game.Bet, where: b.match_id in ^bet_match_ids)

    from(u in Accounts.User,
      where: u.organization == ^organization,
      preload: [bets: ^bets_query]
    )
  end
end

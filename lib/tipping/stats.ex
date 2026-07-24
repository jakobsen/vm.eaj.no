defmodule Tipping.Stats do
  @moduledoc """
  Functions for calculating score statistics for users and organizations.
  """

  alias Tipping.Accounts
  alias Tipping.Game
  alias Tipping.Repo

  def for_organization(organization) do
    Accounts.list_users_in_organization(organization)
    |> Repo.preload(bets: [:match])
    |> Enum.reject(fn user -> user.bets == [] end)
    |> Enum.map(fn user ->
      points = Enum.map(user.bets, fn bet -> Game.bet_points(bet, bet.match) end)
      number_of_bets = length(points)
      total_points = Enum.sum(points)

      %{
        name: user.name,
        total_points: total_points,
        best_streak: best_streak(points),
        worst_streak: worst_streak(points),
        average_score: total_points / number_of_bets,
        three_pointers: Enum.count(points, &(&1 == 3)),
        two_pointers: Enum.count(points, &(&1 == 2)),
        one_pointers: Enum.count(points, &(&1 == 1)),
        misses: Enum.count(points, &(&1 == 0))
      }
    end)
  end

  def best_streak(points) do
    {_, best} =
      Enum.reduce(points, {0, 0}, fn
        0, {_current, best} -> {0, best}
        _, {current, best} -> {current + 1, max(current + 1, best)}
      end)

    best
  end

  def worst_streak(points) do
    {_, worst} =
      Enum.reduce(points, {0, 0}, fn
        x, {_current, worst} when x > 0 -> {0, worst}
        _, {current, worst} -> {current + 1, max(current + 1, worst)}
      end)

    worst
  end
end

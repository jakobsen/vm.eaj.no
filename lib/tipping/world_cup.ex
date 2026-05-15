defmodule Tipping.WorldCup do
  import Ecto.Query

  alias Tipping.Repo
  alias Tipping.WorldCup

  def list_matches(), do: Repo.all(from m in WorldCup.Match, preload: [:home_team, :away_team])
end

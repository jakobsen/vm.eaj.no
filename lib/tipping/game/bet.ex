defmodule Tipping.Game.Bet do
  use Ecto.Schema

  alias Tipping.Accounts
  alias Tipping.WorldCup

  schema "bets" do
    field :home_score, :integer
    field :away_score, :integer
    belongs_to :user, Accounts.User
    belongs_to :match, WorldCup.Match

    timestamps(type: :utc_datetime)
  end
end

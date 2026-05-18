defmodule Tipping.Game.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tipping.Accounts
  alias Tipping.WorldCup

  schema "bets" do
    field :home_score, :integer, default: 0
    field :away_score, :integer, default: 0
    belongs_to :user, Accounts.User
    belongs_to :match, WorldCup.Match

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = bet, attrs) do
    bet
    |> cast(attrs, [:home_score, :away_score])
    |> validate_required([:home_score, :away_score, :user_id, :match_id])
    |> validate_number(:away_score, greater_than_or_equal_to: 0)
    |> validate_number(:home_score, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:match_id)
    |> unique_constraint([:user_id, :match_id])
  end
end

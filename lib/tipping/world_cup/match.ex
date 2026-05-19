defmodule Tipping.WorldCup.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tipping.WorldCup

  schema "matches" do
    field :kickoff_at, :utc_datetime
    field :stage, :string
    belongs_to :home_team, WorldCup.Team
    belongs_to :away_team, WorldCup.Team
    field :home_score, :integer
    field :away_score, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = match, attrs \\ %{}) do
    match
    |> cast(attrs, [:home_team_id, :away_team_id, :home_score, :away_score])
    |> validate_number(:home_score, greater_than_or_equal_to: 0)
    |> validate_number(:away_score, greater_than_or_equal_to: 0)
    |> validate_both_scores()
    |> foreign_key_constraint(:home_team_id)
    |> foreign_key_constraint(:away_team_id)
  end

  defp validate_both_scores(changeset) do
    case {get_change(changeset, :home_score), get_change(changeset, :away_score)} do
      {nil, nil} -> changeset
      {home, away} when is_integer(home) and is_integer(away) -> changeset
      _ -> add_error(changeset, :score, "Both scores must be nil or set")
    end
  end
end

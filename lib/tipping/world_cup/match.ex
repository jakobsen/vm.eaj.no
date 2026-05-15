defmodule Tipping.WorldCup.Match do
  use Ecto.Schema

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
end

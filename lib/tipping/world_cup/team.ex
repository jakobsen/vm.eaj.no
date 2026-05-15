defmodule Tipping.WorldCup.Team do
  use Ecto.Schema

  schema "teams" do
    field :name, :string
    field :fifa_code, :string
    field :group, :string

    timestamps(type: :utc_datetime)
  end
end

defmodule Tipping.Repo.Migrations.AddTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      add :fifa_code, :string, null: false, size: 3
      add :group, :string, null: false, size: 1

      timestamps(type: :utc_datetime)
    end
  end
end

defmodule Tipping.Repo.Migrations.AddMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :kickoff_at, :utc_datetime, null: false
      add :stage, :string, null: false
      add :home_team_id, references(:teams, on_delete: :restrict)
      add :away_team_id, references(:teams, on_delete: :restrict)
      add :home_score, :integer
      add :away_score, :integer

      timestamps(type: :utc_datetime)
    end
  end
end

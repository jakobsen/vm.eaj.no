defmodule Tipping.Repo.Migrations.AddBets do
  use Ecto.Migration

  def change do
    create table(:bets) do
      add :home_score, :integer
      add :away_score, :integer
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :match_id, references(:matches, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:bets, [:match_id])
    create unique_index(:bets, [:user_id, :match_id])
  end
end

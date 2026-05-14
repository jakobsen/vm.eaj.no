defmodule Tipping.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :auth_provider_sub, :string, null: false

      add :email, :string, null: false
      add :name, :string
      add :organization, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:auth_provider_sub])
    create index(:users, [:email])
    create index(:users, [:organization])
  end
end

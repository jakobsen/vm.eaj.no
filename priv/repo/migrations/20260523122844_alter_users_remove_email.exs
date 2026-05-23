defmodule Tipping.Repo.Migrations.AlterUsersRemoveEmail do
  use Ecto.Migration

  def change do
    drop index(:users, [:email])

    alter table(:users) do
      remove :email, :string
    end
  end
end

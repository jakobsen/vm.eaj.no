defmodule Tipping.Repo.Migrations.AlterUsersAddApiKey do
  use Ecto.Migration
  import Ecto.Query

  def up do
    alter table(:users) do
      add :api_key, :string
    end

    flush()

    for user_id <- repo().all(from(u in "users", select: u.id)) do
      api_key = :crypto.strong_rand_bytes(16) |> Base.encode32(case: :lower, padding: false)
      repo().query!("UPDATE users SET api_key = $1 WHERE id = $2", [api_key, user_id])
    end

    create unique_index(:users, [:api_key])
  end

  def down do
    drop index(:users, [:api_key])

    alter table(:users) do
      remove :api_key
    end
  end
end

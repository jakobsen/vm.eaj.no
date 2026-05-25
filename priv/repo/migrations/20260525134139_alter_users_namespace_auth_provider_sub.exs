defmodule Tipping.Repo.Migrations.AlterUsersNamespaceAuthProviderSub do
  use Ecto.Migration

  def up do
    execute """
    UPDATE users
    SET auth_provider_sub = 'google:' || auth_provider_sub
    WHERE auth_provider_sub NOT LIKE 'google:%'
    """
  end

  def down do
    execute """
    UPDATE users
    SET auth_provider_sub = substr(auth_provider_sub, 8)
    WHERE auth_provider_sub LIKE 'google:%'
    """
  end
end

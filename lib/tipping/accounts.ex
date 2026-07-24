defmodule Tipping.Accounts do
  @moduledoc """
  Context concerning users and auth.
  """

  alias Tipping.Accounts.User
  alias Tipping.Repo

  import Ecto.Query

  def get_user_by_id(nil), do: nil
  def get_user_by_id(id), do: Repo.get(User, id)

  def get_user_by_api_key(key) do
    case Repo.get_by(User, api_key: key) do
      %User{} = user -> {:ok, user}
      _ -> {:error, :not_found}
    end
  end

  def get_or_create_user(attrs) do
    case Repo.get_by(User, auth_provider_sub: Map.get(attrs, :auth_provider_sub, "invalid_attrs")) do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      %User{} = user ->
        user
        |> User.changeset(attrs)
        |> Repo.update()
    end
  end

  def list_users_in_organization(organization) do
    Repo.all(from u in User, where: u.organization == ^organization)
  end

  def make_admin(%User{} = user) do
    user |> User.admin_changeset(true) |> Repo.update()
  end

  def generate_api_key() do
    :crypto.strong_rand_bytes(16) |> Base.encode32(padding: false, case: :lower)
  end
end

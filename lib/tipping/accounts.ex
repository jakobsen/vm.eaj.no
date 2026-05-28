defmodule Tipping.Accounts do
  @moduledoc """
  Context concerning users and auth.
  """

  alias Tipping.Accounts.User
  alias Tipping.Repo

  def get_user_by_id(nil), do: nil
  def get_user_by_id(id), do: Repo.get(User, id)

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

  def make_admin(%User{} = user) do
    user |> User.admin_changeset(true) |> Repo.update()
  end
end

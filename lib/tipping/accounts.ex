defmodule Tipping.Accounts do
  alias Tipping.Accounts.User
  alias Tipping.Repo

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
end

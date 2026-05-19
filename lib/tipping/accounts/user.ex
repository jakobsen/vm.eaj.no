defmodule Tipping.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :auth_provider_sub, :string
    field :email, :string
    field :name, :string
    field :organization, :string
    field :admin?, :boolean, source: :is_admin

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:auth_provider_sub, :email, :name, :organization])
    |> validate_required([:auth_provider_sub, :email, :name, :organization])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:auth_provider_sub)
  end

  def admin_changeset(%__MODULE__{} = user, admin?) do
    user
    |> change(%{admin?: admin?})
  end
end

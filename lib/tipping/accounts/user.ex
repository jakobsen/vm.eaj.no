defmodule Tipping.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tipping.Game

  schema "users" do
    field :auth_provider_sub, :string
    field :name, :string
    field :organization, :string
    field :admin?, :boolean, source: :is_admin

    has_many :bets, Game.Bet

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:auth_provider_sub, :name, :organization])
    |> validate_required([:auth_provider_sub, :name, :organization])
    |> unique_constraint(:auth_provider_sub)
  end

  def admin_changeset(%__MODULE__{} = user, admin?) do
    user
    |> change(%{admin?: admin?})
  end
end

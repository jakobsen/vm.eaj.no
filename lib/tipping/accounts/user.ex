defmodule Tipping.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :auth_provider_sub, :string
    field :email, :string
    field :name, :string
    field :organization, :string

    timestamps(type: :utc_datetime)
  end
end

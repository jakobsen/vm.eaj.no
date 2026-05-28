defmodule Tipping.Repo do
  use Ecto.Repo,
    otp_app: :tipping,
    adapter: Ecto.Adapters.SQLite3

  def count(queryable, opts \\ []) do
    aggregate(queryable, :count, opts)
  end
end

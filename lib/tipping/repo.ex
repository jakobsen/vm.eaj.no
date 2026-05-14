defmodule Tipping.Repo do
  use Ecto.Repo,
    otp_app: :tipping,
    adapter: Ecto.Adapters.SQLite3
end

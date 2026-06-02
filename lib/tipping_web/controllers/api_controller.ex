defmodule TippingWeb.ApiController do
  alias Tipping.Game
  use TippingWeb, :controller

  def leaderboard(conn, _params) do
    scores =
      Game.organization_scoreboard(conn.assigns.user)
      |> Enum.map(fn score ->
        %{user: %{name: score.user.name, id: encode_id(score.user.id)}, points: score.points}
      end)

    json(conn, %{leaderboard: scores})
  end

  def encode_id(id) do
    {:ok, sqids} = Sqids.new(alphabet: "23456789acefghjkqrsuwxz", min_length: 5)
    {:ok, encoded_id} = Sqids.encode(sqids, [id])
    encoded_id
  end
end

defmodule TippingWeb.ApiControllerTest do
  alias TippingWeb.ApiController
  use TippingWeb.ConnCase

  import Tipping.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    conn = put_req_header(conn, "authorization", "bearer #{user.api_key}")
    %{conn: conn, user: user}
  end

  describe "GET /api/leaderboard" do
    test "returns an object with a single object representing the current user when user is alone and no bets are scored",
         %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/leaderboard")

      assert json_response(conn, 200) == %{
               "leaderboard" => [
                 %{
                   "user" => %{"name" => user.name, "id" => ApiController.encode_id(user.id)},
                   "points" => 0
                 }
               ]
             }
    end
  end
end

defmodule TippingWeb.PointsTableLiveTest do
  use TippingWeb.ConnCase

  import Tipping.AccountsFixtures

  alias TippingWeb.PointsTableLive

  describe "prepare_table/1" do
    setup do
      %{user: user_fixture()}
    end

    test "preserves points", %{user: user} do
      assert [%{points: 3}, %{points: 3}, %{points: 1}] =
               PointsTableLive.prepare_table(
                 [
                   %{points: 3, user: user},
                   %{points: 3, user: user},
                   %{points: 1, user: user}
                 ],
                 user
               )
    end

    test "removes the user attribute", %{user: user} do
      prepared_table =
        PointsTableLive.prepare_table(
          [
            %{points: 3, user: user},
            %{points: 3, user: user},
            %{points: 1, user: user}
          ],
          user
        )

      assert Enum.all?(prepared_table, &(Map.fetch(&1, :user) == :error))
    end

    test "adds a name to each row" do
      first_user = user_fixture(%{name: "Navn Navnesen"})
      second_user = user_fixture(%{name: "Test Testesen"})

      assert [%{name: "Navn Navnesen"}, %{name: "Test Testesen"}] =
               PointsTableLive.prepare_table(
                 [
                   %{points: 3, user: first_user},
                   %{points: 3, user: second_user}
                 ],
                 first_user
               )
    end

    test "adds a lighter background for the current user_s row", %{user: current_user} do
      another_user = user_fixture()

      assert [%{background: "bg-white/10"}, %{background: "bg-[#27308366]"}] =
               PointsTableLive.prepare_table(
                 [
                   %{points: 0, user: current_user},
                   %{points: 0, user: another_user}
                 ],
                 current_user
               )
    end
  end

  describe "GET /tabell" do
    test "users can see their API key on the page", %{conn: conn} do
      user = user_fixture()
      conn = conn |> init_test_session(%{user_id: user.id}) |> get(~p"/tabell")
      assert html_response(conn, 200) =~ user.api_key
    end

    test "aidn.no users organization heading says Kernel", %{conn: conn} do
      user = user_fixture(organization: "aidn.no")
      conn = conn |> init_test_session(%{user_id: user.id}) |> get(~p"/tabell")
      assert html_response(conn, 200) =~ "Stillingen i Kernel så langt"
    end

    test "deepinsight.io users organization heading says Kernel", %{conn: conn} do
      user = user_fixture(organization: "deepinsight.io")
      conn = conn |> init_test_session(%{user_id: user.id}) |> get(~p"/tabell")
      assert html_response(conn, 200) =~ "Stillingen i Kernel så langt"
    end

    test "users in an unknown organization's heading says the domain name unchanged", %{
      conn: conn
    } do
      org_name =
        :crypto.strong_rand_bytes(4)
        |> Base.encode32(case: :lower, padding: false)
        |> Kernel.<>(".no")

      user = user_fixture(organization: org_name)
      conn = conn |> init_test_session(%{user_id: user.id}) |> get(~p"/tabell")
      assert html_response(conn, 200) =~ "Stillingen i #{org_name} så langt"
    end
  end
end

defmodule TippingWeb.PointsTableLiveTest do
  use Tipping.DataCase

  import Tipping.AccountsFixtures

  alias TippingWeb.PointsTableLive

  describe "prepare_table/1" do
    setup do
      %{user: user_fixture()}
    end

    test "adds a position attribute in ascending order to a list of descending points", %{
      user: user
    } do
      assert [%{position: 1}, %{position: 2}, %{position: 3}] =
               PointsTableLive.prepare_table(
                 [
                   %{points: 3, user: user},
                   %{points: 2, user: user},
                   %{points: 1, user: user}
                 ],
                 user
               )
    end

    test "handles ties", %{user: user} do
      assert [%{position: 1}, %{position: 1}, %{position: 3}] =
               PointsTableLive.prepare_table(
                 [
                   %{points: 3, user: user},
                   %{points: 3, user: user},
                   %{points: 1, user: user}
                 ],
                 user
               )
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
end

defmodule Tipping.AccountsTest do
  use Tipping.DataCase

  alias Tipping.Accounts

  describe "get_or_create_user/1" do
    test "returns an error when invalid data is passed" do
      assert {:error, %Ecto.Changeset{}} = Accounts.get_or_create_user(%{})
    end

    test "creates a user when passed valid data" do
      assert {:ok, %Accounts.User{}} =
               Accounts.get_or_create_user(%{
                 auth_provider_sub: "abc123",
                 email: "user@email.com",
                 name: "That's a great name",
                 organization: "dreng.no"
               })
    end

    test "returns the same user when the user already exists" do
      {:ok, %Accounts.User{} = first_user} =
        Accounts.get_or_create_user(%{
          auth_provider_sub: "abc123",
          email: "user@email.com",
          name: "That's a great name",
          organization: "dreng.no"
        })

      {:ok, %Accounts.User{} = second_user} =
        Accounts.get_or_create_user(%{
          auth_provider_sub: "abc123",
          email: "user@email.com",
          name: "That's a great name",
          organization: "dreng.no"
        })

      assert first_user.id == second_user.id
      assert Repo.aggregate(Accounts.User, :count) == 1
    end

    test "updates the user info when it changes for a given sub" do
      {:ok, %Accounts.User{} = first_user} =
        Accounts.get_or_create_user(%{
          auth_provider_sub: "abc123",
          email: "user@email.com",
          name: "That's a great name",
          organization: "dreng.no"
        })

      {:ok, %Accounts.User{} = second_user} =
        Accounts.get_or_create_user(%{
          auth_provider_sub: "abc123",
          email: "user2@email.com",
          name: "That's an even better name",
          organization: "aidn.no"
        })

      assert first_user.id == second_user.id
      assert second_user.email == "user2@email.com"
      assert second_user.name == "That's an even better name"
      assert second_user.organization == "aidn.no"
    end
  end
end

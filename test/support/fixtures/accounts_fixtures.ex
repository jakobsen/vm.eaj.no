defmodule Tipping.AccountsFixtures do
  alias Tipping.Accounts

  def user_fixture(attrs \\ %{}) do
    {:ok, user} = attrs |> valid_user_attributes() |> Accounts.get_or_create_user()
    user
  end

  def admin_user_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)
    {:ok, user} = Accounts.make_admin(user)
    user
  end

  defp valid_user_attributes(attrs) do
    Enum.into(attrs, %{
      auth_provider_sub: :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false),
      organization: "dreng.no",
      name: "Test Testesen"
    })
  end
end

defmodule TippingWeb.Auth.MicrosoftTest do
  use ExUnit.Case

  alias TippingWeb.Auth.Microsoft

  describe "normalize_claims/1" do
    test "sub is prefixed with `microsoft:`" do
      assert {:ok, %{auth_provider_sub: auth_provider_sub}} =
               Microsoft.normalize_claims(%{
                 "sub" => "abc123",
                 "name" => "Navn",
                 "email" => "vm@eaj.no"
               })

      assert auth_provider_sub == "microsoft:abc123"
    end

    test "organization is extracted from email claim" do
      assert {:ok, %{organization: organization}} =
               Microsoft.normalize_claims(%{
                 "sub" => "abc123",
                 "name" => "Navn",
                 "email" => "vm@eaj.no"
               })

      assert organization == "eaj.no"
    end

    test "organization is extracted from preferred_username claim" do
      assert {:ok, %{organization: organization}} =
               Microsoft.normalize_claims(%{
                 "sub" => "abc123",
                 "name" => "Navn",
                 "preferred_username" => "vm@eaj.no"
               })

      assert organization == "eaj.no"
    end

    test "organization is lowercased" do
      assert {:ok, %{organization: organization}} =
               Microsoft.normalize_claims(%{
                 "sub" => "abc123",
                 "name" => "Navn",
                 "preferred_username" => "vm@AidnAS.onmicrosoft.com"
               })

      assert organization == "aidnas.onmicrosoft.com"
    end
  end
end

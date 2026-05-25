defmodule TippingWeb.Auth.GoogleTest do
  use ExUnit.Case

  alias TippingWeb.Auth.Google

  describe "normalize_claims/1" do
    test "sub is prefixed with `google:`" do
      assert {:ok, %{auth_provider_sub: auth_provider_sub}} =
               Google.normalize_claims(%{"sub" => "abc123", "name" => "Navn", "hd" => "eaj.no"})

      assert auth_provider_sub == "google:abc123"
    end
  end
end

defmodule TippingWeb.Auth.GoogleJwt do
  @jwks_url "https://www.googleapis.com/oauth2/v3/certs"
  @valid_iss ["https://accounts.google.com", "accounts.google.com"]
  @client_id "54992027643-991u17tde1r2fk9g2mvv2ei4cn25cklm.apps.googleusercontent.com"

  def verify_and_validate(jwt) do
    with {:ok, %{"kid" => kid}} <- Joken.peek_header(jwt),
         {:ok, signer} <- fetch_signer(kid),
         {:ok, claims} <- Joken.verify(jwt, signer),
         :ok <- check_claims(claims) do
      {:ok, claims}
    end
  end

  def normalize_claims(claims) do
    types = %{
      auth_provider_sub: :string,
      email: :string,
      name: :string,
      organization: :string
    }

    prepared_data = %{
      auth_provider_sub: claims["sub"],
      email: claims["email"],
      name: claims["name"],
      organization: claims["hd"]
    }

    {%{}, types}
    |> Ecto.Changeset.cast(prepared_data, Map.keys(types))
    |> Ecto.Changeset.validate_required(Map.keys(types))
    |> Ecto.Changeset.apply_action(:normalize)
  end

  defp fetch_signer(kid) do
    with {:ok, %{status: 200, body: %{"keys" => keys}}} <- Req.get(@jwks_url),
         %{} = key <- Enum.find(keys, &(&1["kid"] == kid)) do
      {:ok, Joken.Signer.create("RS256", key)}
    else
      nil -> {:error, :unknown_kid}
      {:ok, %{status: status}} -> {:error, {:jwks_status, status}}
      error -> error
    end
  end

  defp check_claims(%{"iss" => iss, "exp" => exp, "aud" => aud} = claims) do
    cond do
      Map.get(claims, "hd") == nil -> {:error, :not_workspace_account}
      iss not in @valid_iss -> {:error, :wrong_issuer}
      exp <= System.os_time(:second) -> {:error, :expired}
      aud != @client_id -> {:error, :invalid_audience}
      true -> :ok
    end
  end
end

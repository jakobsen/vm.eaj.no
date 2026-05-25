defmodule TippingWeb.Auth.Google do
  use TippingWeb, :verified_routes

  @oauth2_endpoint "https://accounts.google.com/o/oauth2/v2/auth"
  @token_endpoint "https://oauth2.googleapis.com/token"
  @valid_iss ["https://accounts.google.com", "accounts.google.com"]
  @jwks_url "https://www.googleapis.com/oauth2/v3/certs"

  def oauth2_url(state) do
    URI.new!(@oauth2_endpoint) |> URI.append_query(query_params(state)) |> URI.to_string()
  end

  def fetch_id_token(code) do
    %{client_id: client_id, client_secret: client_secret} = config()

    case Req.post(@token_endpoint,
           form: %{
             client_id: client_id,
             client_secret: client_secret,
             code: code,
             grant_type: "authorization_code",
             redirect_uri: redirect_uri()
           }
         ) do
      {:ok, %Req.Response{status: 200, body: %{"id_token" => id_token}}} -> {:ok, id_token}
      {:ok, %Req.Response{} = response} -> {:error, {:bad_status, response}}
      {:error, error} -> {:error, error}
    end
  end

  defp query_params(state) do
    %{client_id: client_id} = config()

    %{
      client_id: client_id,
      redirect_uri: redirect_uri(),
      response_type: "code",
      scope: "openid profile email",
      access_type: "offline",
      state: state
    }
    |> URI.encode_query()
  end

  defp redirect_uri() do
    url(~p"/auth/google/callback")
  end

  def verify_id_token(jwt) do
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
      name: :string,
      organization: :string
    }

    prepared_data = %{
      auth_provider_sub: "google:#{claims["sub"]}",
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
    %{client_id: client_id} = config()

    cond do
      iss not in @valid_iss -> {:error, :wrong_issuer}
      exp <= System.os_time(:second) -> {:error, :expired}
      aud != client_id -> {:error, :invalid_audience}
      Map.get(claims, "hd") == nil -> {:error, :not_workspace_account}
      true -> :ok
    end
  end

  defp config() do
    Application.fetch_env!(:tipping, __MODULE__) |> Map.new()
  end
end

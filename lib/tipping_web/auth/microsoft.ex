defmodule TippingWeb.Auth.Microsoft do
  @oauth2_endpoint "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize"
  @token_endpoint "https://login.microsoftonline.com/organizations/oauth2/v2.0/token"
  @jwks_url "https://login.microsoftonline.com/organizations/discovery/v2.0/keys"

  use TippingWeb, :verified_routes

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
             scope: "openid profile email",
             redirect_uri: redirect_uri(),
             grant_type: "authorization_code"
           }
         ) do
      {:ok, %Req.Response{status: 200, body: %{"id_token" => id_token}}} -> {:ok, id_token}
      {:ok, %Req.Response{} = response} -> {:error, {:bad_status, response}}
      {:error, error} -> {:error, error}
    end
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

    with {:ok, domain} <- extract_domain(claims) do
      prepared_data = %{
        auth_provider_sub: "microsoft:#{claims["sub"]}",
        name: claims["name"],
        organization: domain
      }

      {%{}, types}
      |> Ecto.Changeset.cast(prepared_data, Map.keys(types))
      |> Ecto.Changeset.validate_required(Map.keys(types))
      |> Ecto.Changeset.apply_action(:normalize)
    end
  end

  defp extract_domain(claims) do
    email = claims["email"] || claims["preferred_username"]

    if email == nil or not String.contains?(email, "@") do
      {:error, :invalid_email}
    end

    domain = email |> String.split("@") |> List.last() |> String.downcase()
    {:ok, domain}
  end

  defp query_params(state) do
    %{client_id: client_id} = config()

    URI.encode_query(%{
      client_id: client_id,
      response_type: "code",
      redirect_uri: redirect_uri(),
      response_mode: "query",
      scope: "openid profile email",
      state: state
    })
  end

  defp redirect_uri() do
    url(~p"/auth/microsoft/callback")
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

  defp check_claims(%{"tid" => tid, "exp" => exp, "iss" => iss, "aud" => aud}) do
    %{client_id: client_id} = config()

    cond do
      iss != valid_issuer(tid) -> {:error, :wrong_issuer}
      exp <= System.os_time(:second) -> {:error, :expired}
      aud != client_id -> {:error, :invalid_audience}
      true -> :ok
    end
  end

  defp valid_issuer(tid) do
    "https://login.microsoftonline.com/#{tid}/v2.0"
  end

  defp config() do
    Application.fetch_env!(:tipping, __MODULE__) |> Map.new()
  end
end

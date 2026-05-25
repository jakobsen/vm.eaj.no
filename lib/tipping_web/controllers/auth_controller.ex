defmodule TippingWeb.AuthController do
  use TippingWeb, :controller

  require Logger
  alias Tipping.Accounts
  alias TippingWeb.Auth

  def google_login(conn, _params) do
    state = generate_state()
    redirect_to = Auth.Google.oauth2_url(state)

    conn |> put_session(:g_state, state) |> redirect(external: redirect_to)
  end

  def google_callback(conn, %{"code" => code} = params) do
    cookie_state = get_session(conn, :g_state)
    conn = delete_session(conn, :g_state)

    with :ok <- verify_state(cookie_state, params),
         {:ok, jwt} <- Auth.Google.fetch_id_token(code),
         {:ok, claims} <- Auth.Google.verify_id_token(jwt),
         {:ok, attrs} <- Auth.Google.normalize_claims(claims),
         {:ok, user} <- Accounts.get_or_create_user(attrs) do
      Auth.log_in_user(conn, user)
    else
      {:error, :not_workspace_account} ->
        redirect(conn, to: ~p"/?feil=ikke-bedriftskonto")

      {:error, error} ->
        Logger.error("Google login failed", error: inspect(error))

        conn
        |> put_flash(:error, "Noe gikk galt ved innlogging. Prøv igjen")
        |> redirect(to: ~p"/")
    end
  end

  def microsoft_login(conn, _params) do
    state = generate_state()
    redirect_to = Auth.Microsoft.oauth2_url(state)

    conn |> put_session(:ms_state, state) |> redirect(external: redirect_to)
  end

  def microsoft_callback(conn, %{"code" => code} = params) do
    cookie_state = get_session(conn, :ms_state)
    conn = delete_session(conn, :ms_state)

    with :ok <- verify_state(cookie_state, params),
         {:ok, jwt} <- Auth.Microsoft.fetch_id_token(code),
         {:ok, claims} <- Auth.Microsoft.verify_id_token(jwt),
         {:ok, attrs} <- Auth.Microsoft.normalize_claims(claims),
         {:ok, user} <- Accounts.get_or_create_user(attrs) do
      Auth.log_in_user(conn, user)
    else
      {:error, error} ->
        Logger.error("Google login failed", error: inspect(error))

        conn
        |> put_flash(:error, "Noe gikk galt ved innlogging. Prøv igjen")
        |> redirect(to: ~p"/")
    end
  end

  def log_out(conn, _params) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> put_flash(:info, "Du er logget ut. Velkommen tilbake!")
    |> redirect(to: ~p"/")
  end

  defp generate_state() do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
  end

  defp verify_state(cookie_state, params) do
    params_state = Map.get(params, "state")

    if is_nil(cookie_state) or is_nil(params_state) or
         not Plug.Crypto.secure_compare(cookie_state, params_state) do
      {:error, :bad_state}
    else
      :ok
    end
  end
end

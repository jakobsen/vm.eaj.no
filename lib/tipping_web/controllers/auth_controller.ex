defmodule TippingWeb.AuthController do
  use TippingWeb, :controller

  alias Tipping.Accounts
  alias TippingWeb.Auth

  def log_in(conn, %{"credential" => jwt}) do
    with {:ok, claims} <- Auth.GoogleJwt.verify_and_validate(jwt),
         {:ok, attrs} <- Auth.GoogleJwt.normalize_claims(claims),
         {:ok, user} <- Accounts.get_or_create_user(attrs) do
      Auth.log_in_user(conn, user)
    else
      {:error, :not_workspace_account} ->
        redirect(conn, to: ~p"/?feil=ikke-bedriftskonto")

      {:error, _} ->
        conn
        |> put_flash(:error, "Noe gikk galt ved innlogging. Prøv igjen")
        |> redirect(to: ~p"/")
    end
  end
end

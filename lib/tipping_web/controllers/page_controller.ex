defmodule TippingWeb.PageController do
  use TippingWeb, :controller

  def home(conn, params) do
    render(conn, :home, error_message: error_message(params["feil"]))
  end

  defp error_message("ikke-bedriftskonto"),
    do:
      "Du må logge inn med en Google-konto tilknyttet et Workspace.<br />Personlige Gmail-kontorer er dessverre ikke støttet."

  defp error_message(_), do: nil
end

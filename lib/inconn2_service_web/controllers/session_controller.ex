defmodule Inconn2ServiceWeb.SessionController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.Account.Auth

  def login(conn, %{"username" => username, "password" => password}) do
    prefix = conn.assigns.sub_domain_prefix

    case Auth.authenticate(username, password, prefix) do
      {:ok, user} ->
        conn = Inconn2Service.Guardian.Plug.sign_in(conn, user)
        render(conn, "success.json", %{token: Inconn2Service.Guardian.Plug.current_token(conn)})

      {:error, msg} ->
        # send_resp(conn, :no_content, "")
        # render(conn, "failure.json", %{})
        render(conn, "failure.json", %{error: msg})
    end
  end
end

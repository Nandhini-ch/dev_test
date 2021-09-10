defmodule Inconn2ServiceWeb.SessionController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.Account.Auth

  def login(conn, %{"username" => username, "password" => password}) do
    prefix = conn.assigns.sub_domain_prefix

    case Auth.authenticate(username, password, prefix) do
      {:ok, user} ->
        conn = Inconn2Service.Guardian.Plug.sign_in(conn, user)
        # assign(conn, :current_user, user)

        render(
          conn,
          "success.json",
          %{
            token: Inconn2Service.Guardian.Plug.current_token(conn),
            current_user: user
          }
        )

      {:error, reason} ->
        conn
        |> put_status(401)

        render(conn, "error.json", %{error: reason})
    end
  end
end

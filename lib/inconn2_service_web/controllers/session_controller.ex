defmodule Inconn2ServiceWeb.SessionController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.Account.Auth
  alias Inconn2Service.{AssetConfig, Staff, Account}

  def login(conn, %{"username" => username, "password" => password}) do
    prefix = conn.assigns.sub_domain_prefix

    case Auth.authenticate(username, password, prefix) do
      {:ok, user} ->
        # conn = Inconn2Service.Guardian.Plug.sign_in(conn, user)
        conn =
          Inconn2Service.Guardian.Plug.sign_in(conn, %{
            "user" => user,
            "sub_domain_prefix" => prefix
          })

        render(
          conn,
          "success.json",
          %{
            token: Inconn2Service.Guardian.Plug.current_token(conn)
          }
        )

      {:error, reason} ->
        conn
        |> put_status(401)

        render(conn, "error.json", %{error: reason})
    end
  end

  def current_user(conn, _params) do
    current_user = conn.assigns.current_user
    party_id = current_user.party_id
    username = current_user.username
    employee = Staff.get_employee_email!(username, conn.assigns.sub_domain_prefix)
    party = AssetConfig.get_party!(party_id, conn.assigns.sub_domain_prefix)
    IO.inspect(conn.assigns.sub_domain_prefix)
    licensee = Account.get_licensee_by_sub_domain(conn.assigns.sub_domain)
    render(conn, "current_user.json", current_user: current_user, licensee: licensee, party: party, employee: employee)
  end
end

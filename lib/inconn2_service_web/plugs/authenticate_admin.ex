defmodule Inconn2ServiceWeb.Plugs.AuthenticateAdmin do
  import Plug.Conn
  alias Inconn2Service.Guardian

  def init(_params) do
  end

  def call(conn, _params) do
    ["Bearer " <> token] = get_req_header(conn, "authorization")
    case Guardian.resource_from_token(token) do
      {:ok, _user, claims} ->
        String.split(claims["sub"], "@") |> List.last()
        |> check_for_admin(conn)

      _ ->
        body = Jason.encode!(%{message: "Invalid Token"})
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(402, body)
        |> halt()
    end
  end

  defp check_for_admin("inc_admin", conn), do: conn
  defp check_for_admin(_, conn) do
    body = Jason.encode!(%{message: "Invalid Token"})
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(402, body)
    |> halt()
  end

end

defmodule Inconn2ServiceWeb.Plugs.MatchTenantPlug do
  import Plug.Conn

  alias Inconn2Service.Account
  alias Inconn2Service.Account.Licensee

  def init(_params) do
  end

  def call(conn, _params) do
    host_part = conn.host
    sub_domain = host_part |> String.split(".") |> List.first()

    case Account.get_licensee_by_sub_domain(sub_domain) do
      %Licensee{} ->
        assign(conn, :sub_domain_prefix, Triplex.to_prefix(sub_domain))

      nil ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, "Invalid sub domain")
        |> halt()
    end
  end
end

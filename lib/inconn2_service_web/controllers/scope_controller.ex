defmodule Inconn2ServiceWeb.ScopeController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.Scope

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    scopes = ContractManagement.list_scopes(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", scopes: scopes)
  end

  def create(conn, %{"scope" => scope_params}) do
    case conn.query_params["type"] do
      "by_site" ->
        with {:ok, scopes} <- ContractManagement.create_scope(scope_params, conn.query_params, conn.assigns.sub_domain_prefix) do
          render(conn, "index.json", scopes: scopes)
        end

      "by_location" ->
        with {:ok, %Scope{} = scope} <- ContractManagement.create_scope(scope_params, conn.assigns.sub_domain_prefix) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.scope_path(conn, :show, scope))
          |> render("show.json", scope: scope)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    scope = ContractManagement.get_scope!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", scope: scope)
  end

  def update(conn, %{"id" => id, "scope" => scope_params}) do
    scope = ContractManagement.get_scope!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Scope{} = scope} <- ContractManagement.update_scope(scope, scope_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", scope: scope)
    end
  end

  def delete(conn, %{"id" => id}) do
    scope = ContractManagement.get_scope!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Scope{}} <- ContractManagement.delete_scope(scope, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule Inconn2ServiceWeb.ServiceBranchController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.ServiceBranch

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    service_branches = AssetInfo.list_service_branches(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", service_branches: service_branches)
  end

  def create(conn, %{"service_branch" => service_branch_params}) do
    with {:ok, %ServiceBranch{} = service_branch} <- AssetInfo.create_service_branch(service_branch_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.service_branch_path(conn, :show, service_branch))
      |> render("show.json", service_branch: service_branch)
    end
  end

  def show(conn, %{"id" => id}) do
    service_branch = AssetInfo.get_service_branch!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", service_branch: service_branch)
  end

  def update(conn, %{"id" => id, "service_branch" => service_branch_params}) do
    service_branch = AssetInfo.get_service_branch!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ServiceBranch{} = service_branch} <- AssetInfo.update_service_branch(service_branch, service_branch_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", service_branch: service_branch)
    end
  end

  def delete(conn, %{"id" => id}) do
    service_branch = AssetInfo.get_service_branch!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ServiceBranch{}} <- AssetInfo.delete_service_branch(service_branch, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

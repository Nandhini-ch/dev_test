defmodule Inconn2ServiceWeb.ManpowerConfigurationController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.ManpowerConfiguration

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    manpower_configurations = ContractManagement.list_manpower_configurations(conn.assigns.sub_domain_prefix, conn.query_params)
    render(conn, "index_grouped.json", manpower_configurations: manpower_configurations)
  end

  # def create(conn, %{"manpower_configuration" => manpower_configuration_params}) do
  #   with {:ok, %ManpowerConfiguration{} = manpower_configuration} <- ContractManagement.create_manpower_configuration(manpower_configuration_params, conn.assigns.sub_domain_prefix) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.manpower_configuration_path(conn, :show, manpower_configuration))
  #     |> render("show.json", manpower_configuration: manpower_configuration)
  #   end
  # end

  def create(conn, %{"manpower_configuration" => manpower_configuration_params}) do
    with {:ok, manpower_configurations} <- ContractManagement.create_manpower_configurations(manpower_configuration_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> render("index.json", manpower_configurations: manpower_configurations)
    end
  end

  def show(conn, %{"id" => id}) do
    manpower_configuration = ContractManagement.get_manpower_configuration_with_preloads!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", manpower_configuration: manpower_configuration)
  end

  def update(conn, %{"manpower_configuration" => manpower_configuration_params}) do
    with {:ok, manpower_configurations} <- ContractManagement.update_manpower_configurations(manpower_configuration_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:ok)
      |> render("index.json", manpower_configurations: manpower_configurations)
    end
  end

  def delete(conn, %{"id" => id}) do
    manpower_configuration = ContractManagement.get_manpower_configuration!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ManpowerConfiguration{}} <- ContractManagement.delete_manpower_configuration(manpower_configuration, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule Inconn2ServiceWeb.ContractController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.Contract

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"party_id" => party_id}) do
    contracts = ContractManagement.list_contracts(party_id, conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", contracts: contracts)
  end

  def index(conn, _params) do
    contracts = ContractManagement.list_contracts(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", contracts: contracts)
  end

  def create(conn, %{"contract" => contract_params}) do
    with {:ok, %Contract{} = contract} <- ContractManagement.create_contract(contract_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.contract_path(conn, :show, contract))
      |> render("show.json", contract: contract)
    end
  end

  def show(conn, %{"id" => id}) do
    contract = ContractManagement.get_contract!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", contract: contract)
  end

  def update(conn, %{"id" => id, "contract" => contract_params}) do
    contract = ContractManagement.get_contract!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Contract{} = contract} <- ContractManagement.update_contract(contract, contract_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", contract: contract)
    end
  end

  def delete(conn, %{"id" => id}) do
    contract = ContractManagement.get_contract!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Contract{}} <- ContractManagement.delete_contract(contract, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

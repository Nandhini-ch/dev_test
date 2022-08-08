defmodule Inconn2ServiceWeb.ContractView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{ContractView, ScopeView}

  def render("index.json", %{contracts: contracts}) do
    %{data: render_many(contracts, ContractView, "contract.json")}
  end

  def render("show.json", %{contract: contract}) do
    %{data: render_one(contract, ContractView, "contract.json")}
  end

  def render("contract.json", %{contract: contract}) do
    %{id: contract.id,
      name: contract.name,
      description: contract.description,
      start_date: contract.start_date,
      scopes: render_many(contract.scopes, ScopeView, "scope.json"),
      end_date: contract.end_date,
      is_effective_status: contract.is_effective_status,
      party_id: contract.party_id}
  end
end

defmodule Inconn2Service.ContractManagement.ManpowerConfiguration do
  alias Inconn2Service.ContractManagement.Contract
  use Ecto.Schema
  import Ecto.Changeset

  schema "manpower_configurations" do
    field :designation_id, :integer
    field :quantity, :integer
    field :shift_id, :integer
    field :site_id, :integer
    belongs_to :contract, Contract

    timestamps()
  end

  @doc false
  def changeset(manpower_configuration, attrs) do
    manpower_configuration
    |> cast(attrs, [:site_id, :designation_id, :shift_id, :quantity, :contract_id])
    |> validate_required([:site_id, :shift_id, :contract_id])
  end
end

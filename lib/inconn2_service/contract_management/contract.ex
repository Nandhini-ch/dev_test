defmodule Inconn2Service.ContractManagement.Contract do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Party
  alias Inconn2Service.ContractManagement.Scope

  schema "contracts" do
    field :description, :string
    field :end_date, :date
    field :name, :string
    field :start_date, :date
    field :is_effective_status, :boolean
    belongs_to :party, Party
    has_many :scope, Scope
    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [:name, :description, :start_date, :end_date, :party_id, :is_effective_status])
    |> validate_required([:name, :start_date, :end_date, :party_id, :is_effective_status])
  end
end

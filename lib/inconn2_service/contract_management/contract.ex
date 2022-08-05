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
    field :active, :boolean, default: true
    belongs_to :party, Party
    has_many :scope, Scope
    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [:name, :description, :start_date, :end_date, :party_id, :is_effective_status, :active])
    |> validate_required([:name, :start_date, :end_date, :party_id, :is_effective_status, :active])
    |> validate_contract_date()
  end

  def validate_contract_date(cs) do
    start_date = get_field(cs, :start_date)
    end_date = get_field(cs, :end_date)
    cond do
      !is_nil(start_date) and !is_nil(end_date) and start_date > end_date ->
        add_error(cs, :start_date, "Start date should be lesser than end date")
        |> add_error(:end_date, "Start date should be lesser than end date")

      is_nil(start_date) or !is_nil(end_date) ->
        add_error(cs, :start_date, "Start date or End date missing")
        |> add_error(:end_date, "Start date or End date missing")

      true ->
        cs
    end
  end
end

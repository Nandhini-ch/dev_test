defmodule Inconn2Service.ContractManagement.Scope do
  alias Inconn2Service.ContractManagement.Contract
  alias Inconn2Service.AssetConfig.Site
  use Ecto.Schema
  import Ecto.Changeset

  schema "scopes" do
    field :is_applicable_to_all_asset_category, :boolean, default: false
    field :is_applicable_to_all_location, :boolean, default: false
    field :asset_category_ids, {:array, :integer}
    field :location_ids, {:array, :integer}
    field :name, :string
    belongs_to :site, Site
    belongs_to :contract, Contract
    # field :contract_id, :integer
    # field :site_id, :integer


    timestamps()
  end

  @doc false
  def changeset(scope, attrs) do
    scope
    |> cast(attrs, [:is_applicable_to_all_location, :location_ids, :is_applicable_to_all_asset_category, :asset_category_ids, :start_date, :end_date, :site_id, :contract_id, :name])
    |> validate_required([:is_applicable_to_all_location, :is_applicable_to_all_asset_category, :site_id, :contract_id])
    |> validate_applicable_loc_ids()
    |> validate_applicable_asset_category_ids()
  end

  def validate_applicable_loc_ids(cs) do
    case get_field(cs, :is_applicable_to_all_location) do
      false -> validate_required(cs, [:location_ids])
      _ -> cs
    end
  end

  def validate_applicable_asset_category_ids(cs) do
    case get_field(cs, :is_applicable_to_all_asset_category) do
      false -> validate_required(cs, [:asset_category_ids])
      _ -> cs
    end
  end

end

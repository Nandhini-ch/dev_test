defmodule Inconn2Service.ContractManagement.Scope do
  alias Inconn2Service.ContractManagement.Contract
  alias Inconn2Service.AssetConfig.Site
  use Ecto.Schema
  import Ecto.Changeset

  schema "scopes" do
    field :applicable_to_all_asset_category, :boolean, default: false
    field :applicable_to_all_location, :boolean, default: false
    field :asset_category_ids, {:array, :integer}
    field :location_ids, {:array, :integer}
    belongs_to :contract, Contract
    field :start_date, :date
    field :end_date, :date
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(scope, attrs) do
    scope
    |> cast(attrs, [:applicable_to_all_location, :location_ids, :applicable_to_all_asset_category, :asset_category_ids, :start_date, :end_date])
    |> validate_required([:applicable_to_all_location, :location_ids, :applicable_to_all_asset_category, :asset_category_ids, :start_date, :end_date])
  end
end

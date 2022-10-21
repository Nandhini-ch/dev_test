defmodule Inconn2Service.InventoryManagement.SiteStock do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.InventoryManagement.{InventoryItem, UnitOfMeasurement}

  schema "site_stocks" do
    field :breached_date_time, :naive_datetime
    field :is_msl_breached, :string
    field :quantity, :float
    belongs_to :site, Site
    belongs_to :inventory_item, InventoryItem
    belongs_to :unit_of_measurement, UnitOfMeasurement

    timestamps()
  end

  @doc false
  def changeset(site_stock, attrs) do
    site_stock
    |> cast(attrs, [:quantity, :is_msl_breached, :breached_date_time, :site_id, :inventory_item_id, :unit_of_measurement_id])
    |> validate_required([:quantity, :is_msl_breached, :breached_date_time, :site_id, :inventory_item_id, :unit_of_measurement_id])
    |> validate_inclusion(:is_msl_breached, ["YES", "NO"])
  end
end

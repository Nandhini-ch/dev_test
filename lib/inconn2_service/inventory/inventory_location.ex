defmodule Inconn2Service.Inventory.InventoryLocation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.AssetConfig.Site

  schema "inventory_locations" do
    field :description, :string
    field :name, :string
    belongs_to :site, Site
    field :site_location_id, :integer
    has_many :inventory_transactions, Inconn2Service.Inventory.InventoryTransaction

    timestamps()
  end

  @doc false
  def changeset(inventory_location, attrs) do
    inventory_location
    |> cast(attrs, [:name, :description, :site_id, :site_location_id])
    |> validate_required([:name, :description, :site_id])
  end
end

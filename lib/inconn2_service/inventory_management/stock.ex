defmodule Inconn2Service.InventoryManagement.Stock do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{InventoryItem, Store}

  schema "stocks" do
    field :aisle, :string
    field :bin, :string
    field :row, :string
    field :quantity, :float
    # field :inventory_item_id, :id
    belongs_to :inventory_item, InventoryItem
    # field :store_id, :id
    belongs_to :store, Store

    timestamps()
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, [:store_id, :inventory_item_id, :quantity])
    |> validate_required([:store_id, :inventory_item_id, :quantity])
  end
end

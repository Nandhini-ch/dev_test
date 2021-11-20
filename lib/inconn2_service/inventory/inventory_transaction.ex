defmodule Inconn2Service.Inventory.InventoryTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_transactions" do
    field :price, :float
    field :quantity, :float
    field :reference, :string
    field :supplier_id, :integer
    field :transaction_type, :string
    field :uom_id, :integer
    field :workorder_id, :integer
    field :remarks, :string
    field :cost, :float
    field :cost_unit_uom_id, :integer
    # field :inventory_location_id, :integer
    belongs_to :inventory_location, Inconn2Service.Inventory.InventoryLocation
    # field :item_id, :integer
    belongs_to :item, Inconn2Service.Inventory.Item

    timestamps()
  end

  @doc false
  def changeset(inventory_transaction, attrs) do
    inventory_transaction
    |> cast(attrs, [:transaction_type, :price, :supplier_id, :quantity, :reference, :inventory_location_id, :item_id, :uom_id, :workorder_id, :remarks])
    |> validate_inclusion(:transaction_type, ["IN", "IS", "RT"])
    |> validate_required([:transaction_type, :quantity, :inventory_location_id, :item_id, :uom_id])
    |> validate_for_transaction_type()
  end

  def update_changeset(inventory_transaction, attrs) do
    inventory_transaction
    |> cast(attrs, [:remarks])
    |> validate_required([:remarks])
  end

  defp validate_for_transaction_type(cs) do
    case get_field(cs, :transaction_type, nil) do
      "IN" ->
        validate_required(cs, [:price, :supplier_id])

      "IS" ->
        validate_required(cs, [:workorder_id])

      "RT" ->
        validate_required(cs, [:workorder_id])

      _ ->
        cs
    end
  end
end

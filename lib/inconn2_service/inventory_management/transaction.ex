defmodule Inconn2Service.InventoryManagement.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{InventoryItem, Store, UnitOfMeasurement}

  schema "transactions" do
    field :aisle, :string
    field :approver_user_id, :integer
    field :bin, :string
    field :cost, :float
    field :quantity, :float
    field :remarks, :string
    field :row, :string
    field :transaction_reference, :string
    field :transaction_type, :string
    field :transaction_user_id, :integer
    field :unit_price, :float
    field :work_order_id, :integer
    field :is_approval_required, :boolean, default: false
    field :is_approved, :string
    # field :item_id, :id
    belongs_to :inventory_item, InventoryItem
    # field :unit_of_measurement_id, :id
    belongs_to :unit_of_measurement, UnitOfMeasurement
    # field :store_id, :id
    belongs_to :store, Store

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:transaction_reference, :transaction_type, :inventory_item_id, :unit_of_measurement_id, :store_id, :transaction_user_id, :approver_user_id, :quantity, :unit_price, :aisle, :row, :bin, :cost, :remarks, :is_approval_required, :is_approved])
    |> validate_required([:transaction_reference, :transaction_type , :inventory_item_id, :unit_of_measurement_id, :store_id,:transaction_user_id, :approver_user_id, :quantity, :unit_price, :aisle, :row, :bin, :cost, :remarks])
    |> validate_inclusion(:transaction_type, ["IN",  "IS"])
    |> validate_inclusion(:is_approved, ["YES", "NO"])
  end
end

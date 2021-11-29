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
    field :dc_attachment, :string
    field :dc_attachment_type, :string
    field :dc_reference, :string
    field :dc_date, :date
    field :gate_pass_attachment, :string
    field :gate_pass_attachment_type, :string
    field :gate_pass_reference, :string
    field :gate_pass_date, :date
    field :remaining, :float
    # field :inventory_location_id, :integer
    belongs_to :inventory_location, Inconn2Service.Inventory.InventoryLocation
    # field :item_id, :integer
    belongs_to :item, Inconn2Service.Inventory.Item

    timestamps()
  end

  @doc false
  def changeset(inventory_transaction, attrs) do
    inventory_transaction
    |> cast(attrs, [:transaction_type, :price, :supplier_id, :quantity, :reference, :inventory_location_id, :item_id, :uom_id, :workorder_id, :remarks,
            :dc_attachment, :dc_attachment_type, :dc_reference, :dc_date, :gate_pass_attachment, :gate_pass_attachment_type, :gate_pass_reference, :gate_pass_date,
            :remaining])
    |> validate_inclusion(:transaction_type, ["IN", "IS", "RT", "PRT", "INTR"])
    |> validate_required([:transaction_type, :quantity, :inventory_location_id, :item_id, :uom_id])
    |> validate_for_transaction_type()
    |> set_remaining()
  end

  def update_changeset(inventory_transaction, attrs) do
    inventory_transaction
    |> cast(attrs, [:remaining, :remarks])
  end

  def set_remaining(cs) do
    transaction_type = get_field(cs, :trasaction_type, nil)
    case transaction_type do
      "IN" ->
        change(cs, %{remaining: get_field(cs, :quantity, 0)})

      _ ->
        cs
    end
  end

  defp validate_for_transaction_type(cs) do
    case get_field(cs, :transaction_type, nil) do
      "IN" ->
        validate_required(cs, [:price, :supplier_id, :dc_reference, :dc_date])

      "IS" ->
        validate_required(cs, [:workorder_id])

      "RT" ->
        validate_required(cs, [:workorder_id])

      "PRT" ->
        validate_required(cs, [:gate_pass_reference, :gate_pass_date])

      "OUT" ->
        validate_required(cs, [:gate_pass_reference, :gate_pass_date])

      "INTR" ->
        validate_required(cs, [:gate_pass_reference, :gate_pass_date])

      _ ->
        cs
    end
  end
end

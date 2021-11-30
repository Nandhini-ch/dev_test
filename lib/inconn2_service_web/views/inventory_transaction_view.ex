defmodule Inconn2ServiceWeb.InventoryTransactionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{InventoryTransactionView, ItemView}

  def render("index.json", %{inventory_transactions: inventory_transactions}) do
    %{data: render_many(inventory_transactions, InventoryTransactionView, "inventory_transaction.json")}
  end

  def render("show.json", %{inventory_transaction: inventory_transaction}) do
    %{data: render_one(inventory_transaction, InventoryTransactionView, "inventory_transaction.json")}
  end

  def render("inventory_transaction.json", %{inventory_transaction: inventory_transaction}) do
    %{id: inventory_transaction.id,
      transaction_type: inventory_transaction.transaction_type,
      price: inventory_transaction.price,
      supplier_id: inventory_transaction.supplier_id,
      quantity: inventory_transaction.quantity,
      reference: inventory_transaction.reference,
      inventory_location_id: inventory_transaction.inventory_location_id,
      # item_id: inventory_transaction.item_id,
      item: render_one(inventory_transaction.item, ItemView, "item.json"),
      uom_id: inventory_transaction.uom_id,
      workorder_id: inventory_transaction.workorder_id,
      remarks: inventory_transaction.remarks,
      dc_reference: inventory_transaction.dc_reference,
      dc_date: inventory_transaction.dc_date,
      gate_pass_reference: inventory_transaction.gate_pass_reference,
      gate_pass_date: inventory_transaction.gate_pass_date,
      cost: inventory_transaction.cost,
      cost_unit_uom_id: inventory_transaction.cost_unit_uom_id}
  end
end

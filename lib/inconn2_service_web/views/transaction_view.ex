defmodule Inconn2ServiceWeb.TransactionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{InventoryItemView, StoreView, TransactionView, UnitOfMeasurementView, UserView}

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction_grouped.json", %{transactions: transactions}) do
    # Enum.map(transactions, fn {k, v} -> {k, render_many(v, TransactionView, "transaction.json")} end) |> Enum.into(%{})
    %{data: render_many(transactions, TransactionView, "transaction_for_reference.json")}
  end

  def render("transaction_for_reference.json", %{transaction: transaction_reference}) do
    %{
      reference_no: transaction_reference.reference_no,
      date: transaction_reference.date,
      transaction_type: transaction_reference.transaction_type,
      transaction_user: (if !is_nil(transaction_reference.transaction_user) do transaction_reference.transaction_user.name else nil end),
      transactions: render_many(transaction_reference.transactions, TransactionView, "transaction.json")
    }
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{id: transaction.id,
      transaction_reference: transaction.transaction_reference,
      transaction_type: transaction.transaction_type,
      transaction_user_id: transaction.transaction_user_id,
      transaction_user: (if is_nil(transaction.transaction_user) do nil else render_one(transaction.transaction_user, UserView, "user_without_org_unit.json") end),
      approver_user_id: transaction.approver_user_id,
      approver_user: (if is_nil(transaction.approver_user) do nil else render_one(transaction.approver_user, UserView, "user_without_org_unit.json") end),
      quantity: transaction.quantity,
      unit_price: transaction.unit_price,
      aisle: transaction.aisle,
      row: transaction.row,
      bin: transaction.bin,
      cost: transaction.cost,
      remarks: transaction.remarks,
      dc_no: transaction.dc_no,
      transaction_date: transaction.transaction_date,
      transaction_time: transaction.transaction_time,
      work_order_id: transaction.work_order_id,
      is_approval_required: transaction.is_approval_required,
      is_approved: transaction.is_approved,
      is_acknowledged: transaction.is_acknowledged,
      emp_id: transaction.emp_id,
      authorized_by: transaction.authorized_by,
      department: transaction.department,
      store: render_one(transaction.store, StoreView, "store_without_content.json"),
      status: transaction.status,
      unit_of_measurement: render_one(transaction.unit_of_measurement, UnitOfMeasurementView, "unit_of_measurement_without_category.json"),
      inventory_item: render_one(transaction.inventory_item, InventoryItemView, "inventory_item_without_stock.json")}
  end
end

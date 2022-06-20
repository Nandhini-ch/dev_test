defmodule Inconn2ServiceWeb.TransactionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.TransactionView

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{id: transaction.id,
      transaction_reference: transaction.transaction_reference,
      transaction_type: transaction.transaction_type,
      transaction_user_id: transaction.transaction_user_id,
      approver_user_id: transaction.approver_user_id,
      quantity: transaction.quantity,
      unit_price: transaction.unit_price,
      aisle: transaction.aisle,
      row: transaction.row,
      bin: transaction.bin,
      cost: transaction.cost,
      remarks: transaction.remarks}
  end
end

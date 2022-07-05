defmodule Inconn2ServiceWeb.TransactionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{TransactionView, UserView}

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
      transaction_user: (if is_nil(transaction.transaction_user) do nil else render_one(transaction.transaction_user, UserView, "user_without_org_unit.json") end),
      approver_user_id: transaction.approver_user_id,
      approver_user: (if is_nil(transaction.approver_user) do nil else render_one(transaction.approver_user, UserView, "user_without_org_unit.json") end),
      quantity: transaction.quantity,
      unit_price: transaction.unit_price,
      aisle: transaction.aisle,
      row: transaction.row,
      bin: transaction.bin,
      cost: transaction.cost,
      remarks: transaction.remarks}
  end
end

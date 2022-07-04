defmodule Inconn2ServiceWeb.TransactionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Transaction

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    transactions = InventoryManagement.list_transactions(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def index_to_be_acknowledged(conn, _params) do
    transactions = InventoryManagement.list_transactions_to_be_acknowledged(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def index_to_be_approved(conn, _params) do
    transactions = InventoryManagement.list_transactions_to_be_approved(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %Transaction{} = transaction} <- InventoryManagement.create_transaction(transaction_params,conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def create_multiple(conn, %{"transactions" => transactions}) do
    transactions = InventoryManagement.create_transactions(transactions, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def show(conn, %{"id" => id}) do
    transaction = InventoryManagement.get_transaction!(id,conn.assigns.sub_domain_prefix)
    render(conn, "show.json", transaction: transaction)
  end
end

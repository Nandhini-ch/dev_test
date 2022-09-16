defmodule Inconn2ServiceWeb.TransactionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Transaction

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    transactions = InventoryManagement.list_transactions(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def index_grouped(conn, _params) do
    transactions = InventoryManagement.list_transactions_grouped(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "transaction_grouped.json", transactions: transactions)
  end

  def index_to_be_acknowledged(conn, _params) do
    transactions = InventoryManagement.list_transactions_to_be_acknowledged(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def index_to_be_approved(conn, _params) do
    transactions = InventoryManagement.list_transactions_to_be_approved(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def index_to_be_approved_grouped(conn, _params) do
    transactions = InventoryManagement.list_transactions_to_be_approved_grouped(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "transaction_grouped.json", transactions: transactions)
  end

  def index_submitted_for_approval_grouped(conn, _params) do
    transactions = InventoryManagement.list_transactions_submitted_for_approved_grouped(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def index_prending_to_be_approved(conn, _params) do
    transactions = InventoryManagement.list_pending_transactions_to_be_approved(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
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
    with {:ok, transactions} <- InventoryManagement.create_transactions(transactions, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> render("index.json", transactions: transactions)
    end
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = InventoryManagement.get_transaction!(id, conn.assigns.sub_domain_prefix)
    with {:ok, %Transaction{} = transaction} <- InventoryManagement.update_transaction(transaction, transaction_params,conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def approve_transaction(conn, %{"transaction" => transaction_params}) do
    transactions = InventoryManagement.approve_transactions(transaction_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    render(conn, "index.json", transactions: transactions)
  end

  def issue_approved_transaction(conn, %{"transaction" => transaction_params}) do
    transactions = InventoryManagement.issue_approved_transactions(transaction_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", transactions: transactions)
  end

  def show(conn, %{"id" => id}) do
    transaction = InventoryManagement.get_transaction!(id,conn.assigns.sub_domain_prefix)
    render(conn, "show.json", transaction: transaction)
  end
end

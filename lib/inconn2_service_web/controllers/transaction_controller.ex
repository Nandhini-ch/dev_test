defmodule Inconn2ServiceWeb.TransactionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Transaction

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    transactions = InventoryManagement.list_transactions(conn.assigns.sub_domain_prefix)
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

  def show(conn, %{"id" => id}) do
    transaction = InventoryManagement.get_transaction!(id,conn.assigns.sub_domain_prefix)
    render(conn, "show.json", transaction: transaction)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = InventoryManagement.get_transaction!(id,conn.assigns.sub_domain_prefix)

    with {:ok, %Transaction{} = transaction} <- InventoryManagement.update_transaction(transaction, transaction_params,conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", transaction: transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = InventoryManagement.get_transaction!(id,conn.assigns.sub_domain_prefix)

    with {:ok, %Transaction{}} <- InventoryManagement.delete_transaction(transaction,conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

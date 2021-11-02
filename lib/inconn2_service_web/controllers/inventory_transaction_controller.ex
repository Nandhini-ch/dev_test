defmodule Inconn2ServiceWeb.InventoryTransactionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryTransaction

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    inventory_transactions = Inventory.list_inventory_transactions(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def loc_transaction(conn, %{"inventory_location_id"=> inventory_location_id}) do
    inventory_transactions = Inventory.list_inventory_transactions_for_inventory_location(inventory_location_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def create(conn, %{"inventory_transaction" => inventory_transaction_params}) do
    with {:ok, %InventoryTransaction{} = inventory_transaction} <- Inventory.create_inventory_transaction(inventory_transaction_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.inventory_transaction_path(conn, :show, inventory_transaction))
      |> render("show.json", inventory_transaction: inventory_transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory_transaction = Inventory.get_inventory_transaction!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_transaction: inventory_transaction)
  end

  def update(conn, %{"id" => id, "inventory_transaction" => inventory_transaction_params}) do
    inventory_transaction = Inventory.get_inventory_transaction!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryTransaction{} = inventory_transaction} <- Inventory.update_inventory_transaction(inventory_transaction, inventory_transaction_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", inventory_transaction: inventory_transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory_transaction = Inventory.get_inventory_transaction!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryTransaction{}} <- Inventory.delete_inventory_transaction(inventory_transaction, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

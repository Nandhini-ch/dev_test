defmodule Inconn2ServiceWeb.InventoryTransactionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryTransaction

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    inventory_transactions = Inventory.list_inventory_transactions(conn.assigns.sub_domain_prefix)
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def index_by_transaction_type_purchase(conn, _params) do
    inventory_transactions = Inventory.list_inventory_transactions_by_transaction_type(conn.assigns.sub_domain_prefix, "IN")
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def index_by_transaction_type_issue(conn, _params) do
    inventory_transactions = Inventory.list_inventory_transactions_by_transaction_type(conn.assigns.sub_domain_prefix, "IS")
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def index_by_transaction_type_return(conn, _params) do
    inventory_transactions = Inventory.list_inventory_transactions_by_transaction_type(conn.assigns.sub_domain_prefix, "RT")
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def loc_transaction(conn, %{"inventory_location_id"=> inventory_location_id}) do
    inventory_transactions = Inventory.list_inventory_transactions_for_inventory_location(inventory_location_id, conn.assigns.sub_domain_prefix)
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def loc_transaction_purchase(conn, %{"inventory_location_id"=> inventory_location_id}) do
    inventory_transactions = Inventory.list_inventory_transactions_for_inventory_location_and_type(inventory_location_id, conn.assigns.sub_domain_prefix, "IN")
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def loc_transaction_issue(conn, %{"inventory_location_id"=> inventory_location_id}) do
    inventory_transactions = Inventory.list_inventory_transactions_for_inventory_location_and_type(inventory_location_id, conn.assigns.sub_domain_prefix, "IS")
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", inventory_transactions: inventory_transactions)
  end

  def loc_transaction_return(conn, %{"inventory_location_id"=> inventory_location_id}) do
    inventory_transactions = Inventory.list_inventory_transactions_for_inventory_location_and_type(inventory_location_id, conn.assigns.sub_domain_prefix, "RT")
                             |> Enum.map(fn x ->Inventory.get_item_for_transaction(x, conn.assigns.sub_domain_prefix) end)
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

  def create_inward_transaction_list(conn, %{"transaction_type" => transaction_type, "dc_reference" => dc_reference, "dc_date" => dc_date, "transactions" => transactions}) do
    with {:ok, inventory_transactions} <- Inventory.create_inward_transaction_list(transaction_type, dc_date, dc_reference, transactions, conn.assigns.sub_domain_prefix) do
      render(conn, "index.json", inventory_transactions: inventory_transactions)
    end
  end

  def create_issue_transaction_list(conn, %{"transaction_type" => transaction_type, "workorder_id" => workorder_id,"transactions" => transactions}) do
    with {:ok, inventory_transactions} <- Inventory.create_issue_transaction_list(transaction_type, workorder_id, transactions, conn.assigns.sub_domain_prefix) do
      render(conn, "index.json", inventory_transactions: inventory_transactions)
    end
  end

  def create_purchase_return_transaction_list(conn, %{"transaction_type" => transaction_type, "gate_pass_reference" => gate_pass_reference, "gate_pass_date" => gate_pass_date, "transactions" => transactions}) do
    with {:ok, inventory_transactions} <- Inventory.create_purchase_return_transaction_list(transaction_type, gate_pass_reference, gate_pass_date, transactions, conn.assigns.sub_domain_prefix) do
      render(conn, "index.json", inventory_transactions: inventory_transactions)
    end
  end

  def create_out_transaction_list(conn, %{"transaction_type" => transaction_type, "gate_pass_reference" => gate_pass_reference, "gate_pass_date" => gate_pass_date, "transactions" => transactions}) do
    with {:ok, inventory_transactions} <- Inventory.create_out_transaction_list(transaction_type, gate_pass_reference, gate_pass_date, transactions, conn.assigns.sub_domain_prefix) do
      render(conn, "index.json", inventory_transactions: inventory_transactions)
    end
  end

  def create_intr_transaction_list(conn, %{"transaction_type" => transaction_type, "gate_pass_reference" => gate_pass_reference, "gate_pass_date" => gate_pass_date, "transactions" => transactions}) do
    with {:ok, inventory_transactions} <- Inventory.create_intr_transaction_list(transaction_type, gate_pass_reference, gate_pass_date, transactions, conn.assigns.sub_domain_prefix) do
      render(conn, "index.json", inventory_transactions: inventory_transactions)
    end
  end

  def create_inis_transaction_list(conn, %{"transaction_type" => transaction_type, "issue_reference" => issue_reference, "user_id" => user_id, "transactions" => transactions}) do
    with {:ok, inventory_transactions} <- Inventory.create_intr_transaction_list(transaction_type, issue_reference, user_id, transactions, conn.assigns.sub_domain_prefix) do
      render(conn, "index.json", inventory_transactions: inventory_transactions)
    end
  end


  def show(conn, %{"id" => id}) do
    inventory_transaction = Inventory.get_inventory_transaction!(id, conn.assigns.sub_domain_prefix)
                            |> Inventory.get_item_for_transaction(conn.assigns.sub_domain_prefix)
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

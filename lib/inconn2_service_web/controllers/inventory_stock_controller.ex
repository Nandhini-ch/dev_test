defmodule Inconn2ServiceWeb.InventoryStockController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryStock

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"inventory_location_id" => inventory_location_id}) do
    inventory_stocks = Inventory.list_inventory_stocks(inventory_location_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_stocks: inventory_stocks)
  end

  def create(conn, %{"inventory_stock" => inventory_stock_params}) do
    with {:ok, %InventoryStock{} = inventory_stock} <- Inventory.create_inventory_stock(inventory_stock_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.inventory_stock_path(conn, :show, inventory_stock))
      |> render("show.json", inventory_stock: inventory_stock)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory_stock = Inventory.get_inventory_stock!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_stock: inventory_stock)
  end

  def stock_for_item(conn, %{"item_id" => item_id}) do
    inventory_stock = Inventory.get_stock_for_item(item_id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_stock: inventory_stock)
  end

  def update(conn, %{"id" => id, "inventory_stock" => inventory_stock_params}) do
    inventory_stock = Inventory.get_inventory_stock!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryStock{} = inventory_stock} <- Inventory.update_inventory_stock(inventory_stock, inventory_stock_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", inventory_stock: inventory_stock)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory_stock = Inventory.get_inventory_stock!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryStock{}} <- Inventory.delete_inventory_stock(inventory_stock, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

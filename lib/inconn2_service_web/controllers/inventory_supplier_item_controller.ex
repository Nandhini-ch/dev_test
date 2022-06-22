defmodule Inconn2ServiceWeb.InventorySupplierItemController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.InventorySupplierItem

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    inventory_supplier_items = InventoryManagement.list_inventory_supplier_items(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_supplier_items: inventory_supplier_items)
  end

  def create(conn, %{"inventory_supplier_item" => inventory_supplier_item_params}) do
    with {:ok, %InventorySupplierItem{} = inventory_supplier_item} <- InventoryManagement.create_inventory_supplier_item(inventory_supplier_item_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.inventory_supplier_item_path(conn, :show, inventory_supplier_item))
      |> render("show.json", inventory_supplier_item: inventory_supplier_item)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory_supplier_item = InventoryManagement.get_inventory_supplier_item!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_supplier_item: inventory_supplier_item)
  end

  def update(conn, %{"id" => id, "inventory_supplier_item" => inventory_supplier_item_params}) do
    inventory_supplier_item = InventoryManagement.get_inventory_supplier_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventorySupplierItem{} = inventory_supplier_item} <- InventoryManagement.update_inventory_supplier_item(inventory_supplier_item, inventory_supplier_item_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", inventory_supplier_item: inventory_supplier_item)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory_supplier_item = InventoryManagement.get_inventory_supplier_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventorySupplierItem{}} <- InventoryManagement.delete_inventory_supplier_item(inventory_supplier_item, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

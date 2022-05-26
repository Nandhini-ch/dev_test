defmodule Inconn2ServiceWeb.InventoryItemController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.InventoryItem

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    inventory_items = InventoryManagement.list_inventory_items(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_items: inventory_items)
  end

  def create(conn, %{"inventory_item" => inventory_item_params}) do
    with {:ok, %InventoryItem{} = inventory_item} <- InventoryManagement.create_inventory_item(inventory_item_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.inventory_item_path(conn, :show, inventory_item))
      |> render("show.json", inventory_item: inventory_item)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory_item = InventoryManagement.get_inventory_item!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_item: inventory_item)
  end

  def update(conn, %{"id" => id, "inventory_item" => inventory_item_params}) do
    inventory_item = InventoryManagement.get_inventory_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryItem{} = inventory_item} <- InventoryManagement.update_inventory_item(inventory_item, inventory_item_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", inventory_item: inventory_item)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory_item = InventoryManagement.get_inventory_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryItem{}} <- InventoryManagement.delete_inventory_item(inventory_item, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

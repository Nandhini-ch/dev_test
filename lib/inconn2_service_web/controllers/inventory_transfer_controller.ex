defmodule Inconn2ServiceWeb.InventoryTransferController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryTransfer

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    inventory_transfers = Inventory.list_inventory_transfers(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_transfers: inventory_transfers)
  end

  def loc_transfer(conn, %{"inventory_location_id" => inventory_location_id}) do
    inventory_transfers = Inventory.list_inventory_transfer_for_inventory_location(inventory_location_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_transfers: inventory_transfers)
  end

  def create(conn, %{"inventory_transfer" => inventory_transfer_params}) do
    with {:ok, %InventoryTransfer{} = inventory_transfer} <- Inventory.create_inventory_transfer(inventory_transfer_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.inventory_transfer_path(conn, :show, inventory_transfer))
      |> render("show.json", inventory_transfer: inventory_transfer)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory_transfer = Inventory.get_inventory_transfer!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_transfer: inventory_transfer)
  end

  def update(conn, %{"id" => id, "inventory_transfer" => inventory_transfer_params}) do
    inventory_transfer = Inventory.get_inventory_transfer!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryTransfer{} = inventory_transfer} <- Inventory.update_inventory_transfer(inventory_transfer, inventory_transfer_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", inventory_transfer: inventory_transfer)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory_transfer = Inventory.get_inventory_transfer!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryTransfer{}} <- Inventory.delete_inventory_transfer(inventory_transfer, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

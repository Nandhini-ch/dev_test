defmodule Inconn2ServiceWeb.InventoryLocationController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryLocation

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    inventory_locations = Inventory.list_inventory_locations(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_locations: inventory_locations)
  end

  def create(conn, %{"inventory_location" => inventory_location_params}) do
    with {:ok, %InventoryLocation{} = inventory_location} <- Inventory.create_inventory_location(inventory_location_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.inventory_location_path(conn, :show, inventory_location))
      |> render("show.json", inventory_location: inventory_location)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory_location = Inventory.get_inventory_location!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_location: inventory_location)
  end

  def update(conn, %{"id" => id, "inventory_location" => inventory_location_params}) do
    inventory_location = Inventory.get_inventory_location!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryLocation{} = inventory_location} <- Inventory.update_inventory_location(inventory_location, inventory_location_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", inventory_location: inventory_location)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory_location = Inventory.get_inventory_location!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventoryLocation{}} <- Inventory.delete_inventory_location(inventory_location, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

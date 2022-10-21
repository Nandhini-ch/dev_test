defmodule Inconn2ServiceWeb.InventorySupplierController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.InventorySupplier

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    inventory_suppliers = InventoryManagement.list_inventory_suppliers(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", inventory_suppliers: inventory_suppliers)
  end

  def create(conn, %{"inventory_supplier" => inventory_supplier_params}) do
    with {:ok, %InventorySupplier{} = inventory_supplier} <- InventoryManagement.create_inventory_supplier(inventory_supplier_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.inventory_supplier_path(conn, :show, inventory_supplier))
      |> render("show.json", inventory_supplier: inventory_supplier)
    end
  end

  def show(conn, %{"id" => id}) do
    inventory_supplier = InventoryManagement.get_inventory_supplier!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", inventory_supplier: inventory_supplier)
  end

  def update(conn, %{"id" => id, "inventory_supplier" => inventory_supplier_params}) do
    inventory_supplier = InventoryManagement.get_inventory_supplier!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %InventorySupplier{} = inventory_supplier} <- InventoryManagement.update_inventory_supplier(inventory_supplier, inventory_supplier_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", inventory_supplier: inventory_supplier)
    end
  end

  def delete(conn, %{"id" => id}) do
    inventory_supplier = InventoryManagement.get_inventory_supplier!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <- InventoryManagement.delete_inventory_supplier(inventory_supplier, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

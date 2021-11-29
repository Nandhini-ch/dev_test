defmodule Inconn2ServiceWeb.SupplierItemController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.SupplierItem

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    supplier_items = Inventory.list_supplier_items(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", supplier_items: supplier_items)
  end

  def create(conn, %{"supplier_item" => supplier_item_params}) do
    with {:ok, %SupplierItem{} = supplier_item} <- Inventory.create_supplier_item(supplier_item_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.supplier_item_path(conn, :show, supplier_item))
      |> render("show.json", supplier_item: supplier_item)
    end
  end

  def show(conn, %{"id" => id}) do
    supplier_item = Inventory.get_supplier_item!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", supplier_item: supplier_item)
  end

  def update(conn, %{"id" => id, "supplier_item" => supplier_item_params}) do
    supplier_item = Inventory.get_supplier_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SupplierItem{} = supplier_item} <- Inventory.update_supplier_item(supplier_item, supplier_item_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", supplier_item: supplier_item)
    end
  end

  def get_suppliers_for_item(conn, %{"item_id" => item_id}) do
    supplier_items = Inventory.get_supplier_for_item(item_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", supplier_items: supplier_items)
  end

  def delete(conn, %{"id" => id}) do
    supplier_item = Inventory.get_supplier_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SupplierItem{}} <- Inventory.delete_supplier_item(supplier_item, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

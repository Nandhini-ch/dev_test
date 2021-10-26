defmodule Inconn2ServiceWeb.SupplierController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.Supplier

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    suppliers = Inventory.list_suppliers(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", suppliers: suppliers)
  end

  def create(conn, %{"supplier" => supplier_params}) do
    with {:ok, %Supplier{} = supplier} <- Inventory.create_supplier(supplier_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.supplier_path(conn, :show, supplier))
      |> render("show.json", supplier: supplier)
    end
  end

  def show(conn, %{"id" => id}) do
    supplier = Inventory.get_supplier!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", supplier: supplier)
  end

  def update(conn, %{"id" => id, "supplier" => supplier_params}) do
    supplier = Inventory.get_supplier!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Supplier{} = supplier} <- Inventory.update_supplier(supplier, supplier_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", supplier: supplier)
    end
  end

  def delete(conn, %{"id" => id}) do
    supplier = Inventory.get_supplier!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Supplier{}} <- Inventory.delete_supplier(supplier, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

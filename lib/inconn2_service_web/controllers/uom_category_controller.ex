defmodule Inconn2ServiceWeb.UomCategoryController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.UomCategory

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    uom_categories = InventoryManagement.list_uom_categories(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", uom_categories: uom_categories)
  end

  def create(conn, %{"uom_category" => uom_category_params}) do
    with {:ok, %UomCategory{} = uom_category} <- InventoryManagement.create_uom_category(uom_category_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.uom_category_path(conn, :show, uom_category))
      |> render("show.json", uom_category: uom_category)
    end
  end

  def show(conn, %{"id" => id}) do
    uom_category = InventoryManagement.get_uom_category!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", uom_category: uom_category)
  end

  def update(conn, %{"id" => id, "uom_category" => uom_category_params}) do
    uom_category = InventoryManagement.get_uom_category!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UomCategory{} = uom_category} <- InventoryManagement.update_uom_category(uom_category, uom_category_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", uom_category: uom_category)
    end
  end

  def delete(conn, %{"id" => id}) do
    uom_category = InventoryManagement.get_uom_category!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UomCategory{}} <- InventoryManagement.delete_uom_category(uom_category, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

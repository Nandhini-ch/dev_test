defmodule Inconn2ServiceWeb.StoreController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Store

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    stores = InventoryManagement.list_stores(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", stores: stores)
  end

  def index_by_site(conn, %{"site_id" => site_id}) do
    stores = InventoryManagement.list_stores_by_site(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", stores: stores)
  end

  def create(conn, %{"store" => store_params}) do
    with {:ok, %Store{} = store} <- InventoryManagement.create_store(store_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.store_path(conn, :show, store))
      |> render("show.json", store: store)
    end
  end

  def show(conn, %{"id" => id}) do
    store = InventoryManagement.get_store!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", store: store)
  end

  def update(conn, %{"id" => id, "store" => store_params}) do
    store = InventoryManagement.get_store!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Store{} = store} <- InventoryManagement.update_store(store, store_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", store: store)
    end
  end

  def delete(conn, %{"id" => id}) do
    store = InventoryManagement.get_store!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Store{}} <- InventoryManagement.delete_store(store, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

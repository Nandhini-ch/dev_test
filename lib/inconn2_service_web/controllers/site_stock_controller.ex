defmodule Inconn2ServiceWeb.SiteStockController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.SiteStock

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    site_stocks = InventoryManagement.list_site_stocks(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", site_stocks: site_stocks)
  end

  def create(conn, %{"site_stock" => site_stock_params}) do
    with {:ok, %SiteStock{} = site_stock} <- InventoryManagement.create_site_stock(site_stock_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.site_stock_path(conn, :show, site_stock))
      |> render("show.json", site_stock: site_stock)
    end
  end

  def show(conn, %{"id" => id}) do
    site_stock = InventoryManagement.get_site_stock!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", site_stock: site_stock)
  end

  def update(conn, %{"id" => id, "site_stock" => site_stock_params}) do
    site_stock = InventoryManagement.get_site_stock!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SiteStock{} = site_stock} <- InventoryManagement.update_site_stock(site_stock, site_stock_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", site_stock: site_stock)
    end
  end

  def delete(conn, %{"id" => id}) do
    site_stock = InventoryManagement.get_site_stock!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SiteStock{}} <- InventoryManagement.delete_site_stock(site_stock, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

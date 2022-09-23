defmodule Inconn2ServiceWeb.StockController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    stocks = InventoryManagement.list_stocks(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", stocks: stocks)
  end

  def index_for_storekeeper(conn, _params) do
    stocks = InventoryManagement.list_stocks_for_storekeeper(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", stocks: stocks)
  end

  def show(conn, %{"id" => id}) do
    stock = InventoryManagement.get_stock!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", stock: stock)
  end
end

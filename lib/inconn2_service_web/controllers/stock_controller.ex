defmodule Inconn2ServiceWeb.StockController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Stock

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    stocks = InventoryManagement.list_stocks(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", stocks: stocks)
  end

  def create(conn, %{"stock" => stock_params}) do
    with {:ok, %Stock{} = stock} <- InventoryManagement.create_stock(stock_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.stock_path(conn, :show, stock))
      |> render("show.json", stock: stock)
    end
  end

  def show(conn, %{"id" => id}) do
    stock = InventoryManagement.get_stock!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", stock: stock)
  end

  def update(conn, %{"id" => id, "stock" => stock_params}) do
    stock = InventoryManagement.get_stock!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Stock{} = stock} <- InventoryManagement.update_stock(stock, stock_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", stock: stock)
    end
  end

  def delete(conn, %{"id" => id}) do
    stock = InventoryManagement.get_stock!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Stock{}} <- InventoryManagement.delete_stock(stock, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule Inconn2ServiceWeb.StockView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{InventoryItemView, StoreView, StockView}

  def render("index.json", %{stocks: stocks}) do
    %{data: render_many(stocks, StockView, "stock.json")}
  end

  def render("show.json", %{stock: stock}) do
    %{data: render_one(stock, StockView, "stock.json")}
  end

  def render("stock_without_item.json", %{stock: stock}) do
    %{id: stock.id,
      inventory_item_id: stock.inventory_item_id,
      quantity: stock.quantity,
      store_id: stock.store_id,
      store: render_one(stock.store, StoreView, "store_without_content.json"),
      aisle: stock.aisle,
      row: stock.row,
      bin: stock.bin}
  end

  def render("stock.json", %{stock: stock}) do
    %{id: stock.id,
      inventory_item_id: stock.inventory_item_id,
      inventory_item: render_one(stock.inventory_item, InventoryItemView, "inventory_item_without_stock.json"),
      quantity: stock.quantity,
      store_id: stock.store_id,
      store: render_one(stock.store, StoreView, "store_without_content.json"),
      aisle: stock.aisle,
      row: stock.row,
      bin: stock.bin}
  end
end

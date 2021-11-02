defmodule Inconn2ServiceWeb.InventoryStockView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.InventoryStockView

  def render("index.json", %{inventory_stocks: inventory_stocks}) do
    %{data: render_many(inventory_stocks, InventoryStockView, "inventory_stock.json")}
  end

  def render("show.json", %{inventory_stock: inventory_stock}) do
    %{data: render_one(inventory_stock, InventoryStockView, "inventory_stock.json")}
  end

  def render("inventory_stock.json", %{inventory_stock: inventory_stock}) do
    %{id: inventory_stock.id,
      inventory_location_id: inventory_stock.inventory_location_id,
      item_id: inventory_stock.item_id,
      quantity: inventory_stock.quantity}
  end
end

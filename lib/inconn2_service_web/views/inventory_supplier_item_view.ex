defmodule Inconn2ServiceWeb.InventorySupplierItemView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.InventorySupplierItemView

  def render("index.json", %{inventory_supplier_items: inventory_supplier_items}) do
    %{data: render_many(inventory_supplier_items, InventorySupplierItemView, "inventory_supplier_item.json")}
  end

  def render("show.json", %{inventory_supplier_item: inventory_supplier_item}) do
    %{data: render_one(inventory_supplier_item, InventorySupplierItemView, "inventory_supplier_item.json")}
  end

  def render("inventory_supplier_item.json", %{inventory_supplier_item: inventory_supplier_item}) do
    %{id: inventory_supplier_item.id}
  end
end

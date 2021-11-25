defmodule Inconn2ServiceWeb.SupplierItemView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{SupplierItemView, SupplierView, ItemView}

  def render("index.json", %{supplier_items: supplier_items}) do
    %{data: render_many(supplier_items, SupplierItemView, "supplier_item.json")}
  end

  def render("show.json", %{supplier_item: supplier_item}) do
    %{data: render_one(supplier_item, SupplierItemView, "supplier_item.json")}
  end

  def render("supplier_item.json", %{supplier_item: supplier_item}) do
    %{id: supplier_item.id,
      supplier_id: supplier_item.supplier_id,
      item_id: supplier_item.item_id,
      item: render_one(supplier_item.item, ItemView, "item.json"),
      supplier: render_one(supplier_item.supplier, SupplierView, "supplierinventory.json"),
      supplier_part_no: supplier_item.supplier_part_no,
      price: supplier_item.price,
      price_unit_uom_id: supplier_item.price_unit_uom_id}
  end
end

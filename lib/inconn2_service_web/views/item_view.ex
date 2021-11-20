defmodule Inconn2ServiceWeb.ItemView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ItemView

  def render("index.json", %{items: items}) do
    %{data: render_many(items, ItemView, "item.json")}
  end

  def render("show.json", %{item: item}) do
    %{data: render_one(item, ItemView, "item.json")}
  end

  def render("item.json", %{item: item}) do
    IO.inspect(item)
    %{id: item.id,
      part_no: item.part_no,
      name: item.name,
      type: item.type,
      purchase_unit_uom_id: item.purchase_unit_uom_id,
      inventory_unit_uom_id: item.inventory_unit_uom_id,
      consume_unit_uom_id: item.consume_unit_uom_id,
      reorder_quantity: item.reorder_quantity,
      min_order_quantity: item.min_order_quantity,
      asset_categories_ids: item.asset_categories_ids,
      aisle: item.aisle,
      bin: item.bin,
      row: item.row}
  end
end

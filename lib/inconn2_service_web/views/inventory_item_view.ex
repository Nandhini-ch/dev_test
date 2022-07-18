defmodule Inconn2ServiceWeb.InventoryItemView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{AssetCategoryView, InventoryItemView, StoreView}
  alias Inconn2ServiceWeb.{UomCategoryView, UnitOfMeasurementView}

  def render("index.json", %{inventory_items: inventory_items}) do
    %{data: render_many(inventory_items, InventoryItemView, "inventory_item.json")}
  end

  def render("show.json", %{inventory_item: inventory_item}) do
    %{data: render_one(inventory_item, InventoryItemView, "inventory_item.json")}
  end

  def render("inventory_item_without_stock.json", %{inventory_item: inventory_item}) do
    %{id: inventory_item.id,
      name: inventory_item.name,
      part_no: inventory_item.part_no,
      item_type: inventory_item.item_type,
      minimum_stock_level: inventory_item.minimum_stock_level,
      remarks: inventory_item.remarks,
      attachment: inventory_item.attachment,
      uom_category_id: inventory_item.uom_category_id,
      unit_price: inventory_item.unit_price,
      is_approval_required: inventory_item.is_approval_required,
      approval_user_id: inventory_item.approval_user_id,
      asset_category_ids: inventory_item.asset_category_ids}
  end

  def render("inventory_item.json", %{inventory_item: inventory_item}) do
    %{id: inventory_item.id,
      name: inventory_item.name,
      part_no: inventory_item.part_no,
      item_type: inventory_item.item_type,
      minimum_stock_level: inventory_item.minimum_stock_level,
      stocked_quantity: inventory_item.stocked_quantity,
      stores: render_many(inventory_item.stocks, StoreView, "store_without_content.json"),
      remarks: inventory_item.remarks,
      attachment: inventory_item.attachment,
      uom_category_id: inventory_item.uom_category_id,
      uom_category: render_one(inventory_item.uom_category, UomCategoryView, "uom_category.json"),
      consume_unit_of_measurement: render_one(inventory_item.consume_unit_of_measurement, UnitOfMeasurementView, "unit_of_measurement_without_category.json"),
      inventory_unit_of_measurement: render_one(inventory_item.inventory_unit_of_measurement, UnitOfMeasurementView, "unit_of_measurement_without_category.json"),
      purchase_unit_of_measurement: render_one(inventory_item.purchase_unit_of_measurement, UnitOfMeasurementView, "unit_of_measurement_without_category.json"),
      unit_price: inventory_item.unit_price,
      is_approval_required: inventory_item.is_approval_required,
      approval_user_id: inventory_item.approval_user_id,
      asset_category_ids: inventory_item.asset_category_ids,
      asset_categories: render_many(inventory_item.asset_categories, AssetCategoryView, "asset_category.json")}
  end
end

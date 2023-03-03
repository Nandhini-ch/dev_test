defmodule Inconn2ServiceWeb.EquipmentManufacturerView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.EquipmentManufacturerView

  def render("index.json", %{equipment_manufacturers: equipment_manufacturers}) do
    %{data: render_many(equipment_manufacturers, EquipmentManufacturerView, "equipment_manufacturer.json")}
  end

  def render("show.json", %{equipment_manufacturer: equipment_manufacturer}) do
    %{data: render_one(equipment_manufacturer, EquipmentManufacturerView, "equipment_manufacturer.json")}
  end

  def render("equipment_manufacturer.json", %{equipment_manufacturer: equipment_manufacturer}) do
    %{id: equipment_manufacturer.id,
      name: equipment_manufacturer.name,
      model_no: equipment_manufacturer.model_no,
      serial_no: equipment_manufacturer.serial_no,
      capacity: equipment_manufacturer.capacity,
      unit_of_capacity: equipment_manufacturer.unit_of_capacity,
      year_of_manufacturing: equipment_manufacturer.year_of_manufacturing,
      acquired_date: equipment_manufacturer.acquired_date,
      commissioned_date: equipment_manufacturer.commissioned_date,
      purchase_price: equipment_manufacturer.purchase_price,
      depreciation_factor: equipment_manufacturer.depreciation_factor,
      description: equipment_manufacturer.description,
      is_warranty_available: equipment_manufacturer.is_warranty_available,
      warranty_from: equipment_manufacturer.warranty_from,
      warranty_to: equipment_manufacturer.warranty_to,
      manufacturer: equipment_manufacturer.manufacturer,
      service_branch: equipment_manufacturer.service_branch,
      country_of_origin: equipment_manufacturer.country_of_origin}
  end
end

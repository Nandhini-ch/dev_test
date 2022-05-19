defmodule Inconn2ServiceWeb.EquipmentMaintenanceVendorView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.EquipmentMaintenanceVendorView

  def render("index.json", %{equipment_maintenance_vendors: equipment_maintenance_vendors}) do
    %{data: render_many(equipment_maintenance_vendors, EquipmentMaintenanceVendorView, "equipment_maintenance_vendor.json")}
  end

  def render("show.json", %{equipment_maintenance_vendor: equipment_maintenance_vendor}) do
    %{data: render_one(equipment_maintenance_vendor, EquipmentMaintenanceVendorView, "equipment_maintenance_vendor.json")}
  end

  def render("equipment_maintenance_vendor.json", %{equipment_maintenance_vendor: equipment_maintenance_vendor}) do
    %{id: equipment_maintenance_vendor.id,
      vendor_scope: equipment_maintenance_vendor.vendor_scope,
      is_asset_under_amc: equipment_maintenance_vendor.is_asset_under_amc,
      amc_from: equipment_maintenance_vendor.amc_from,
      amc_to: equipment_maintenance_vendor.amc_to,
      amc_frequency: equipment_maintenance_vendor.amc_frequency,
      response_time_in_minutes: equipment_maintenance_vendor.response_time_in_minutes,
      vendor_id: equipment_maintenance_vendor.vendor_id,
      service_branch_id: equipment_maintenance_vendor.service_branch_id}
  end
end

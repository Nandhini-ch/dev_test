defmodule Inconn2ServiceWeb.EquipmentDlpVendorView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.EquipmentDlpVendorView

  def render("index.json", %{equipment_dlp_vendors: equipment_dlp_vendors}) do
    %{data: render_many(equipment_dlp_vendors, EquipmentDlpVendorView, "equipment_dlp_vendor.json")}
  end

  def render("show.json", %{equipment_dlp_vendor: equipment_dlp_vendor}) do
    %{data: render_one(equipment_dlp_vendor, EquipmentDlpVendorView, "equipment_dlp_vendor.json")}
  end

  def render("equipment_dlp_vendor.json", %{equipment_dlp_vendor: equipment_dlp_vendor}) do
    %{id: equipment_dlp_vendor.id,
      vendor_scope: equipment_dlp_vendor.vendor_scope,
      is_asset_under_dlp: equipment_dlp_vendor.is_asset_under_dlp,
      dlp_from: equipment_dlp_vendor.dlp_from,
      dlp_to: equipment_dlp_vendor.dlp_to,
      vendor: equipment_dlp_vendor.vendor,
      service_branch_id: equipment_dlp_vendor.service_branch_id}
  end
end

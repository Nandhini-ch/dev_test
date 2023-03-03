defmodule Inconn2ServiceWeb.EquipmentInsuranceVendorView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.EquipmentInsuranceVendorView

  def render("index.json", %{equipment_insurance_vendors: equipment_insurance_vendors}) do
    %{data: render_many(equipment_insurance_vendors, EquipmentInsuranceVendorView, "equipment_insurance_vendor.json")}
  end

  def render("show.json", %{equipment_insurance_vendor: equipment_insurance_vendor}) do
    %{data: render_one(equipment_insurance_vendor, EquipmentInsuranceVendorView, "equipment_insurance_vendor.json")}
  end

  def render("equipment_insurance_vendor.json", %{equipment_insurance_vendor: equipment_insurance_vendor}) do
    %{id: equipment_insurance_vendor.id,
      insurance_policy_no: equipment_insurance_vendor.insurance_policy_no,
      insurance_scope: equipment_insurance_vendor.insurance_scope,
      start_date: equipment_insurance_vendor.start_date,
      end_date: equipment_insurance_vendor.end_date,
      vendor: equipment_insurance_vendor.vendor,
      service_branch: equipment_insurance_vendor.service_branch}
  end
end

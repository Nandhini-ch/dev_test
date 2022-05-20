defmodule Inconn2ServiceWeb.EquipmentInsuranceVendorController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentInsuranceVendor

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    equipment_insurance_vendors = AssetInfo.list_equipment_insurance_vendors(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_insurance_vendors: equipment_insurance_vendors)
  end

  def index_by_equipment_id(conn, %{"equipment_id" => equipment_id}) do
    equipment_insurance_vendors = AssetInfo.list_equipment_insurance_vendors_by_equipment_id(equipment_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_insurance_vendors: equipment_insurance_vendors)
  end

  def create(conn, %{"equipment_insurance_vendor" => equipment_insurance_vendor_params}) do
    with {:ok, %EquipmentInsuranceVendor{} = equipment_insurance_vendor} <- AssetInfo.create_equipment_insurance_vendor(equipment_insurance_vendor_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.equipment_insurance_vendor_path(conn, :show, equipment_insurance_vendor))
      |> render("show.json", equipment_insurance_vendor: equipment_insurance_vendor)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment_insurance_vendor = AssetInfo.get_equipment_insurance_vendor!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", equipment_insurance_vendor: equipment_insurance_vendor)
  end

  def update(conn, %{"id" => id, "equipment_insurance_vendor" => equipment_insurance_vendor_params}) do
    equipment_insurance_vendor = AssetInfo.get_equipment_insurance_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentInsuranceVendor{} = equipment_insurance_vendor} <- AssetInfo.update_equipment_insurance_vendor(equipment_insurance_vendor, equipment_insurance_vendor_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment_insurance_vendor: equipment_insurance_vendor)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment_insurance_vendor = AssetInfo.get_equipment_insurance_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentInsuranceVendor{}} <- AssetInfo.delete_equipment_insurance_vendor(equipment_insurance_vendor, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

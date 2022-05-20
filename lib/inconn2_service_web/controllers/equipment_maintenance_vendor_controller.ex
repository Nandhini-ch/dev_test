defmodule Inconn2ServiceWeb.EquipmentMaintenanceVendorController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentMaintenanceVendor

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    equipment_maintenance_vendors = AssetInfo.list_equipment_maintenance_vendors(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_maintenance_vendors: equipment_maintenance_vendors)
  end

  def index_by_equipment_id(conn, %{"equipment_id" => equipment_id}) do
    equipment_maintenance_vendors = AssetInfo.list_equipment_maintenance_vendors_by_equipment_id(equipment_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_maintenance_vendors: equipment_maintenance_vendors)
  end

  def create(conn, %{"equipment_maintenance_vendor" => equipment_maintenance_vendor_params}) do
    with {:ok, %EquipmentMaintenanceVendor{} = equipment_maintenance_vendor} <- AssetInfo.create_equipment_maintenance_vendor(equipment_maintenance_vendor_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.equipment_maintenance_vendor_path(conn, :show, equipment_maintenance_vendor))
      |> render("show.json", equipment_maintenance_vendor: equipment_maintenance_vendor)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment_maintenance_vendor = AssetInfo.get_equipment_maintenance_vendor!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", equipment_maintenance_vendor: equipment_maintenance_vendor)
  end

  def update(conn, %{"id" => id, "equipment_maintenance_vendor" => equipment_maintenance_vendor_params}) do
    equipment_maintenance_vendor = AssetInfo.get_equipment_maintenance_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentMaintenanceVendor{} = equipment_maintenance_vendor} <- AssetInfo.update_equipment_maintenance_vendor(equipment_maintenance_vendor, equipment_maintenance_vendor_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment_maintenance_vendor: equipment_maintenance_vendor)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment_maintenance_vendor = AssetInfo.get_equipment_maintenance_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentMaintenanceVendor{}} <- AssetInfo.delete_equipment_maintenance_vendor(equipment_maintenance_vendor, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

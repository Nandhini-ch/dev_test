defmodule Inconn2ServiceWeb.EquipmentMaintenanceVendorController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentMaintenanceVendor

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    equipment_maintenance_vendors = AssetInfo.list_equipment_maintenance_vendors()
    render(conn, "index.json", equipment_maintenance_vendors: equipment_maintenance_vendors)
  end

  def create(conn, %{"equipment_maintenance_vendor" => equipment_maintenance_vendor_params}) do
    with {:ok, %EquipmentMaintenanceVendor{} = equipment_maintenance_vendor} <- AssetInfo.create_equipment_maintenance_vendor(equipment_maintenance_vendor_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.equipment_maintenance_vendor_path(conn, :show, equipment_maintenance_vendor))
      |> render("show.json", equipment_maintenance_vendor: equipment_maintenance_vendor)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment_maintenance_vendor = AssetInfo.get_equipment_maintenance_vendor!(id)
    render(conn, "show.json", equipment_maintenance_vendor: equipment_maintenance_vendor)
  end

  def update(conn, %{"id" => id, "equipment_maintenance_vendor" => equipment_maintenance_vendor_params}) do
    equipment_maintenance_vendor = AssetInfo.get_equipment_maintenance_vendor!(id)

    with {:ok, %EquipmentMaintenanceVendor{} = equipment_maintenance_vendor} <- AssetInfo.update_equipment_maintenance_vendor(equipment_maintenance_vendor, equipment_maintenance_vendor_params) do
      render(conn, "show.json", equipment_maintenance_vendor: equipment_maintenance_vendor)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment_maintenance_vendor = AssetInfo.get_equipment_maintenance_vendor!(id)

    with {:ok, %EquipmentMaintenanceVendor{}} <- AssetInfo.delete_equipment_maintenance_vendor(equipment_maintenance_vendor) do
      send_resp(conn, :no_content, "")
    end
  end
end

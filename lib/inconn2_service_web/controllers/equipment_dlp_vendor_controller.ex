defmodule Inconn2ServiceWeb.EquipmentDlpVendorController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentDlpVendor

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    equipment_dlp_vendors = AssetInfo.list_equipment_dlp_vendors(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_dlp_vendors: equipment_dlp_vendors)
  end

  def create(conn, %{"equipment_dlp_vendor" => equipment_dlp_vendor_params}) do
    with {:ok, %EquipmentDlpVendor{} = equipment_dlp_vendor} <- AssetInfo.create_equipment_dlp_vendor(equipment_dlp_vendor_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.equipment_dlp_vendor_path(conn, :show, equipment_dlp_vendor))
      |> render("show.json", equipment_dlp_vendor: equipment_dlp_vendor)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment_dlp_vendor = AssetInfo.get_equipment_dlp_vendor!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", equipment_dlp_vendor: equipment_dlp_vendor)
  end

  def update(conn, %{"id" => id, "equipment_dlp_vendor" => equipment_dlp_vendor_params}) do
    equipment_dlp_vendor = AssetInfo.get_equipment_dlp_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentDlpVendor{} = equipment_dlp_vendor} <- AssetInfo.update_equipment_dlp_vendor(equipment_dlp_vendor, equipment_dlp_vendor_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment_dlp_vendor: equipment_dlp_vendor)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment_dlp_vendor = AssetInfo.get_equipment_dlp_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentDlpVendor{}} <- AssetInfo.delete_equipment_dlp_vendor(equipment_dlp_vendor, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

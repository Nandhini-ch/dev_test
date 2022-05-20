defmodule Inconn2ServiceWeb.EquipmentManufacturerController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentManufacturer

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    equipment_manufacturers = AssetInfo.list_equipment_manufacturers(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_manufacturers: equipment_manufacturers)
  end

  def index_by_equipment_id(conn, %{"equipment_id" => equipment_id}) do
    equipment_manufacturers = AssetInfo.list_equipment_manufacturers_by_equipment_id(equipment_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_manufacturers: equipment_manufacturers)
  end

  def create(conn, %{"equipment_manufacturer" => equipment_manufacturer_params}) do
    with {:ok, %EquipmentManufacturer{} = equipment_manufacturer} <- AssetInfo.create_equipment_manufacturer(equipment_manufacturer_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.equipment_manufacturer_path(conn, :show, equipment_manufacturer))
      |> render("show.json", equipment_manufacturer: equipment_manufacturer)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment_manufacturer = AssetInfo.get_equipment_manufacturer!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", equipment_manufacturer: equipment_manufacturer)
  end

  def update(conn, %{"id" => id, "equipment_manufacturer" => equipment_manufacturer_params}) do
    equipment_manufacturer = AssetInfo.get_equipment_manufacturer!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentManufacturer{} = equipment_manufacturer} <- AssetInfo.update_equipment_manufacturer(equipment_manufacturer, equipment_manufacturer_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment_manufacturer: equipment_manufacturer)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment_manufacturer = AssetInfo.get_equipment_manufacturer!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentManufacturer{}} <- AssetInfo.delete_equipment_manufacturer(equipment_manufacturer, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

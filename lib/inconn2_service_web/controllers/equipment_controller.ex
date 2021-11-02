defmodule Inconn2ServiceWeb.EquipmentController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Equipment

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"site_id" => site_id}) do
    equipments = AssetConfig.list_equipments(site_id, conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipments: equipments)
  end

  def tree(conn, %{"site_id" => site_id}) do
    equipments = AssetConfig.list_equipments_tree(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "tree.json", equipments: equipments)
  end

  def leaves(conn, %{"site_id" => site_id}) do
    equipments = AssetConfig.list_equipments_leaves(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipments: equipments)
  end

  def loc_equipments(conn, %{"location_id" => location_id}) do
    equipments = AssetConfig.list_equipments_of_location(location_id, conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json",equipments: equipments)
  end

  def create(conn, %{"equipment" => equipment_params}) do
    with {:ok, %Equipment{} = equipment} <-
           AssetConfig.create_equipment(equipment_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("equipment", Routes.equipment_path(conn, :show, equipment))
      |> render("show.json", equipment: equipment)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", equipment: equipment)
  end

  def loc_path(conn, %{"equipment_id" => equipment_id}) do
    locations = AssetConfig.location_path_of_equipments(equipment_id, conn.assigns.sub_domain_prefix)
    render(conn, "location_index.json", locations: locations)
  end

  def update(conn, %{"id" => id, "equipment" => equipment_params}) do
    equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Equipment{} = equipment} <-
           AssetConfig.update_equipment(equipment, equipment_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment: equipment)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)

    with {_, nil} <-
           AssetConfig.delete_equipment(equipment, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_equipment(conn, %{"id" => id, "site_id" => site_id}) do
    equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Equipment{} = equipment} <-
           AssetConfig.update_active_status_for_equipment(equipment, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment: equipment)
    end
  end

  def deactivate_equipment(conn, %{"id" => id, "site_id" => site_id}) do
    equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Equipment{} = equipment} <-
           AssetConfig.update_active_status_for_equipment(equipment, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment: equipment)
    end
  end

end

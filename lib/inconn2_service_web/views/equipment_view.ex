defmodule Inconn2ServiceWeb.EquipmentView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.EquipmentView

  def render("index.json", %{equipments: equipments}) do
    %{data: render_many(equipments, EquipmentView, "equipment.json")}
  end

  def render("tree.json", %{equipments: equipments}) do
    %{data: render_many(equipments, EquipmentView, "equipment_node.json")}
  end

  def render("show.json", %{equipment: equipment}) do
    %{data: render_one(equipment, EquipmentView, "equipment.json")}
  end

  def render("asset_qrs.json", %{equipments: equipments}) do
    %{data: render_many(equipments, EquipmentView, "asset_qr.json")}
  end

  def render("asset_qr.json", %{equipment: equipment}) do
    %{
      id: equipment.id,
      asset_name: equipment.asset_name,
      asset_code: equipment.asset_code,
      asset_qr_ul: equipment.asset_qr_url
    }
  end

  def render("equipment_asset.json", %{equipment: equipment}) do
    %{
      id: equipment.id,
      name: equipment.name,
      equipment_code: equipment.equipment_code,
      location_id: equipment.location_id,
      site_id: equipment.site_id,
      qr_code: equipment.qr_code,
      parent: (if is_nil(equipment.parent), do: nil, else: %{id: equipment.parent.id, name: equipment.parent.name}),
      asset_category_id: equipment.asset_category_id,
      status: equipment.status,
      criticality: equipment.criticality,
      connections_in: equipment.connections_in,
      connections_out: equipment.connections_out,
      parent_id: List.last(equipment.path),
      custom: equipment.custom
    }
  end

  def render("group_update.json", %{update_info: update_info}) do
    update_info
  end


  def render("equipment.json", %{equipment: equipment}) do
    %{
      id: equipment.id,
      name: equipment.name,
      equipment_code: equipment.equipment_code,
      location_id: equipment.location_id,
      site_id: equipment.site_id,
      qr_code: equipment.qr_code,
      asset_category_id: equipment.asset_category_id,
      status: equipment.status,
      criticality: equipment.criticality,
      connections_in: equipment.connections_in,
      connections_out: equipment.connections_out,
      parent_id: List.last(equipment.path),
      tag_name: equipment.tag_name,
      description: equipment.description,
      function: equipment.function,
      asset_owned_by_id: equipment.asset_owned_by_id,
      is_movable: equipment.is_movable,
      department: equipment.department,
      asset_manager_id: equipment.asset_manager_id,
      maintenance_manager_id: equipment.maintenance_manager_id,
      created_on: equipment.created_on,
      asset_class: equipment.asset_class,
      custom: equipment.custom
    }
  end

  def render("equipment_node.json", %{equipment: equipment}) do
    %{
      id: equipment.id,
      name: equipment.name,
      equipment_code: equipment.equipment_code,
      location_id: equipment.location_id,
      site_id: equipment.site_id,
      asset_category_id: equipment.asset_category_id,
      status: equipment.status,
      criticality: equipment.criticality,
      connections_in: equipment.connections_in,
      connections_out: equipment.connections_out,
      qr_code: equipment.qr_code,
      parent_id: List.last(equipment.path),
      children: render_many(equipment.children, EquipmentView, "equipment_node.json"),
      tag_name: equipment.tag_name,
      description: equipment.description,
      function: equipment.function,
      asset_owned_by_id: equipment.asset_owned_by_id,
      is_movable: equipment.is_movable,
      department: equipment.department,
      asset_manager_id: equipment.asset_manager_id,
      maintenance_manager_id: equipment.maintenance_manager_id,
      created_on: equipment.created_on,
      asset_class: equipment.asset_class,
      custom: equipment.custom
    }
  end

  def render("location_index.json", %{locations: locations}) do
    %{data: render_many(locations, EquipmentView, "location.json")}
  end
  def render("location.json", %{equipment: location}) do
    %{
      id: location.id,
      name: location.name
    }
  end

end

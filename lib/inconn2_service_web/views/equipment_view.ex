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

  def render("equipment.json", %{equipment: equipment}) do
    %{
      id: equipment.id,
      name: equipment.name,
      equipment_code: equipment.equipment_code,
      location_id: equipment.location_id,
      site_id: equipment.site_id,
      asset_category_id: equipment.asset_category_id,
      connections_in: equipment.connections_in,
      connections_out: equipment.connections_out,
      parent_id: List.last(equipment.path)
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
      connections_in: equipment.connections_in,
      connections_out: equipment.connections_out,
      parent_id: List.last(equipment.path),
      children: render_many(equipment.children, EquipmentView, "equipment_node.json")
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

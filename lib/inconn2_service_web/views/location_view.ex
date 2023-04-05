defmodule Inconn2ServiceWeb.LocationView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.LocationView

  def render("index.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "location.json")}
  end

  def render("tree.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "location_node.json")}
  end

  def render("show.json", %{location: location}) do
    %{data: render_one(location, LocationView, "location.json")}
  end

  def render("asset_qrs.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "asset_qr.json")}
  end

  def render("location_asset.json", %{location: location}) do
    %{
      id: location.id,
      name: location.name,
      is_iot_enabled: location.is_iot_enabled,
      iot_details: location.iot_details,
      description: location.description,
      location_code: location.location_code,
      site_id: location.site_id,
      status: location.status,
      criticality: location.criticality,
      asset_category_id: location.asset_category_id,
      qr_code: location.qr_code,
      parent: (if is_nil(location.parent), do: nil, else: %{id: location.parent.id, name: location.parent.name})
    }
  end

  def render("location_only_name.json", %{location: location}) do
    %{
      id: location.id,
      name: location.name
    }
  end

  def render("group_update.json", %{update_info: update_info}) do
    update_info
  end


  def render("asset_qr.json", %{location: location}) do
    %{
      id: location.id,
      asset_name: location.asset_name,
      asset_code: location.asset_code,
      asset_qr_ul: location.asset_qr_url
    }
  end

  #arunvr@ardhika.com

  def render("location.json", %{location: location}) do
    %{
      id: location.id,
      name: location.name,
      is_iot_enabled: location.is_iot_enabled,
      iot_details: location.iot_details,
      description: location.description,
      location_code: location.location_code,
      site_id: location.site_id,
      status: location.status,
      criticality: location.criticality,
      asset_category_id: location.asset_category_id,
      qr_code: location.qr_code,
      parent_id: List.last(location.path)
    }
  end

  def render("location_node.json", %{location: location}) do
    %{
      id: location.id,
      name: location.name,
      is_iot_enabled: location.is_iot_enabled,
      iot_details: location.iot_details,
      description: location.description,
      location_code: location.location_code,
      site_id: location.site_id,
      status: location.status,
      criticality: location.criticality,
      asset_category_id: location.asset_category_id,
      qr_code: location.qr_code,
      parent_id: List.last(location.path),
      children: render_many(location.children, LocationView, "location_node.json")
    }
  end

  def render("assets.json", %{locations: locations, equipments: equipments}) do
    %{data:
        render_many(locations, LocationView, "location_asset_node.json") ++
        render_many(equipments, LocationView, "equipment_asset_node.json")
      }
  end

  def render("location_asset_node.json", %{location: asset}) do
    %{
      id: asset.id,
      name: asset.name,
      type: "L"
    }
  end

  def render("equipment_asset_node.json", %{location: asset}) do
    %{
      id: asset.id,
      name: asset.name,
      type: "E"
    }
  end
end

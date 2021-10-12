defmodule Inconn2Service.ReferenceDataDownloader do

  alias Inconn2Service.AssetConfig

  def download_locations(prefix) do
    locations = AssetConfig.list_active_locations(prefix)

    header = [["id", "reference", "Name", "Description", "Location Code", "Asset Category Id", "Site Id", "Parent Id", "parent reference"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.description, r.location_code, r.asset_category_id, r.site_id, List.last(r.path), ""]
      end)

    final_report = header ++ body
    final_report
  end

  def download_equipments(prefix) do
    locations = AssetConfig.list_equipments(prefix)

    header = [["id", "reference", "Name", "Equipment Code", "Site Id", "Location Id", "Asset Category Id", "Connections In", "Connections Out", "Parent Id", "parent reference"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.equipment_code, r.site_id, r.location_id, r.asset_category_id, r.connections_in, r.connections_out, List.last(r.path), ""]
      end)

    final_report = header ++ body
    final_report
  end

  def download_sites(prefix) do
    locations = AssetConfig.list_sites(prefix)

    header = [["id", "reference", "Name", "Description", "Branch", "Latitude", "Longitude", "Fencing Radius", "Site Code", "Time Zone", "Party Id"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.description, r.branch, r.latitude, r.longitude, r.fencing_radius, r.site_code, r.time_zone, r.party_id]
      end)

    final_report = header ++ body
    final_report
  end

end

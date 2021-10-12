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

end

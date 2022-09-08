defmodule Inconn2Service.Dashboards.Helpers do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.AssetConfig

  def get_assets_for_dashboards(site_id, type, prefix) do
    config = get_site_config_for_dashboards(site_id, prefix)
    case type do
      "G" ->
        config["generators"]
        |> convert_nil_to_list()
        |> get_generators(prefix)

      _ ->
        config[match_type_and_config_key(type)]
        |> get_meters(prefix)
    end
  end

  defp match_type_and_config_key(type) do
    case type do
      "E" -> "energy_asset_category"
      "W" -> "water_asset_category"
      "F" -> "fuel_asset_category"
    end
  end

  defp get_generators(asset_ids, prefix), do: AssetConfig.list_equipments_by_ids(asset_ids, prefix)

  defp get_meters(nil, _prefix), do: []
  defp get_meters(asset_category_id, prefix), do: AssetConfig.get_assets_by_asset_category_id(asset_category_id, prefix)

end

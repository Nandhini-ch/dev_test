defmodule Inconn2Service.Dashboards.Helpers do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.NumericalData
  alias Inconn2Service.{AssetConfig, Staff, Settings}

  def get_assets_for_dashboards(site_id, type, prefix) do
    config = get_site_config_for_dashboards(site_id, prefix)
    case type do
      "G" ->
        config["generators"]
        |> convert_nil_to_list()
        |> get_generators(prefix)

      _ ->
        config[match_ac_type_and_config_key(type)]
        |> get_meters(prefix)
    end
  end

  defp match_ac_type_and_config_key(type) do
    case type do
      "E" -> "energy_asset_category"
      "W" -> "water_asset_category"
      "F" -> "fuel_asset_category"
    end
  end

  defp match_main_meters_type_and_config_key(type) do
    case type do
      "E" -> "energy_main_meters"
      "W" -> "water_main_meters"
      "F" -> "fuel_main_meters"
    end
  end

  defp get_generators(asset_ids, prefix), do: AssetConfig.list_equipments_by_ids(asset_ids, prefix)

  defp get_meters(nil, _prefix), do: []
  defp get_meters(asset_category_id, prefix), do: AssetConfig.get_assets_by_asset_category_id(asset_category_id, prefix)

  def get_energey_sub_meters(config, "E", prefix) do
    asset_category_id = config[match_ac_type_and_config_key("E")]
    sub_meters_ids = config["energy_sub_meters"] |> convert_nil_to_list()
    AssetConfig.list_equipments_of_asset_category_and_in_given_ids(asset_category_id, sub_meters_ids, prefix)
  end

  def get_sub_meter_assets(config, meter_type, prefix) do
    asset_category_id = config[match_ac_type_and_config_key(meter_type)]
    main_meter_ids = config[match_main_meters_type_and_config_key(meter_type)] |> convert_nil_to_list() |> convert_config_main_meters()
    AssetConfig.list_equipments_of_asset_category_and_not_in_given_ids(asset_category_id, main_meter_ids, prefix)
  end

  defp convert_config_main_meters(meters) do
    Enum.map(meters, fn meter ->
      if is_map(meter) do
        meter["id"]
      else
        meter
      end
    end)
  end


  def get_assets_and_energy_list(assets, from_dt, to_dt, prefix) do
    assets
      |> Stream.map(&Task.async(fn -> get_asset_and_energy_tuple(&1, from_dt, to_dt, prefix) end))
      |> Stream.map(&Task.await/1)
      |> Enum.sort_by(fn {_asset, value} -> value end, :desc)
  end

  defp get_asset_and_energy_tuple(asset, from_dt, to_dt, prefix) do
    {
      asset,
      NumericalData.get_energy_consumption_for_asset(asset, from_dt, to_dt, prefix)
      |> change_nil_to_zero()
    }
  end

  def get_org_units_tuple(nil, prefix) do
    Staff.list_org_units(prefix)
    |> Enum.map(fn ou -> {ou.name, ou.id} end)
  end

  def get_org_units_tuple(org_unit_ids, prefix) do
    org_unit_ids
    |> Staff.get_org_units_by_ids(prefix)
    |> Enum.map(fn ou -> {ou.name, ou.id} end)
  end

  def get_shifts_tuple(nil, site_id, prefix) do
    Settings.list_shifts(site_id, prefix)
    |> Enum.map(fn shift -> {shift.name, shift.id} end)
  end

  def get_shifts_tuple(shift_ids, _site_id, prefix) do
    shift_ids
    |> Settings.get_shifts_by_ids(prefix)
    |> Enum.map(fn shift -> {shift.name, shift.id} end)
  end

  def get_top_10_data(data_list, key) do
    data_list
    |> Enum.sort_by(&(sort_value(&1, key)), &>=/2)
    |> Enum.take(10)
  end

  defp sort_value(data_map, key) do
    Enum.take_while(data_map.dataSets, fn m -> key in Map.values(m) end)
  end

end

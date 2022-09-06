defmodule Inconn2Service.Dashboards.DashboardCharts do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.NumericalData
  alias Inconn2Service.AssetConfig

  #Energy meters
  def get_energy_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_energy_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_energy_performance_indicator(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_performance_indicator(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_water_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_water_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_water_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_water_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_fuel_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_fuel_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_fuel_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_fuel_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  defp get_individual_energy_consumption_data(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    energy_main_meters = convert_nil_to_list(config["energy_main_meters"])
    value =
      NumericalData.get_energy_consumption_for_assets(
                      energy_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

    %{
      date: date,
      dataSets: [
        %{
          name: "Energy Consumption",
          value: value
        }
      ]
    }
  end

  defp get_individual_energy_cost_for_assets(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    energy_cost_per_unit = change_nil_to_zero(config["energy_cost_per_unit"])
    asset_ids = convert_string_list_to_list(params["asset_ids"])

    data_sets =
          Enum.map(asset_ids, fn asset_id ->
            energy_consumption = NumericalData.get_energy_consumption_for_asset(
                                    asset_id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: energy_consumption * energy_cost_per_unit
            }

          end)

    %{
      date: date,
      dataSets: data_sets
    }

  end

  defp get_individual_energy_performance_indicator(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    energy_main_meters = convert_nil_to_list(config["energy_main_meters"])
    energy_consumption =
      NumericalData.get_energy_consumption_for_assets(
                      energy_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

      area_in_sqft = change_nil_to_one(config["area"])
      epi = energy_consumption / area_in_sqft

    %{
      date: date,
      dataSets: [
        %{
          name: "EPI",
          value: epi
        }
      ]
    }
  end

  defp get_individual_water_consumption_data(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    water_main_meters = convert_nil_to_list(config["water_main_meters"])
    value =
      NumericalData.get_water_consumption_for_assets(
                      water_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

    %{
      date: date,
      dataSets: [
        %{
          name: "Water Consumption",
          value: value
        }
      ]
    }
  end

  defp get_individual_water_cost_for_assets(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    water_cost_per_unit = change_nil_to_zero(config["water_cost_per_unit"])
    asset_ids = convert_string_list_to_list(params["asset_ids"])

    data_sets =
          Enum.map(asset_ids, fn asset_id ->
            water_consumption = NumericalData.get_water_consumption_for_asset(
                                    asset_id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: water_consumption * water_cost_per_unit
            }

          end)

    %{
      date: date,
      dataSets: data_sets
    }

  end

  defp get_individual_fuel_consumption_data(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    fuel_main_meters = convert_nil_to_list(config["fuel_main_meters"])
    value =
      NumericalData.get_fuel_consumption_for_assets(
                      fuel_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

    %{
      date: date,
      dataSets: [
        %{
          name: "Fuel Consumption",
          value: value
        }
      ]
    }
  end

  defp get_individual_fuel_cost_for_assets(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    fuel_cost_per_unit = change_nil_to_zero(config["fuel_cost_per_unit"])
    asset_ids = convert_string_list_to_list(params["asset_ids"])

    data_sets =
          Enum.map(asset_ids, fn asset_id ->
            fuel_consumption = NumericalData.get_fuel_consumption_for_asset(
                                    asset_id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: fuel_consumption * fuel_cost_per_unit
            }

          end)

    %{
      date: date,
      dataSets: data_sets
    }

  end
end

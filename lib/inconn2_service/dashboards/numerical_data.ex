defmodule Inconn2Service.Dashboards.NumericalData do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Measurements.MeterReading

  def get_energy_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_energy_consumption_for_assets(asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id in ^asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_water_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_water_consumption_for_assets(asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id in ^asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "W" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_fuel_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_fuel_consumption_for_assets(asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id in ^asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "F" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_asset(asset_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_water_consumption_for_asset(asset_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "W" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end


  def get_fuel_consumption_for_asset(asset_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "F" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_site(site_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.site_id == ^site_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_site(site_id, exclude_asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.site_id == ^site_id and
                        mr.asset_id not in ^exclude_asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

end

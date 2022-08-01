defmodule Inconn2Service.Util.DeleteManager do
  import Inconn2Service.Util.IndexQueries

  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.Repo
  alias Inconn2Service.InventoryManagement.Store
  alias Inconn2Service.AssetConfig.{Equipment, Location}


  def has_employee_rosters?(%Site{} = site, prefix), do: (employee_rosters_query(EmployeeRoster,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_shift?(%Site{} = site, prefix), do: (shift_query(Shift,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_store?(%Site{} = site, prefix), do: (store_query(Store,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_equipment?(%Site{} = site, prefix), do: (equipment_query(Equipment,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_equipment?(%Location{} = location, prefix), do: (equipment_query(Equipment,%{"location_id" => location.id}) |>Repo.all(prefix: prefix) |> length()) > 0

  def has_location?(%Site{} = site, prefix), do: (location_query(Location,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workorder_schedule(%Location{} = location, prefix), do: (workorder_schedule_query(WorkorderSchedule,%{"asset_id" => location.id, "asset_type" => "L"}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_schedule(%Equipment{} = equipment, prefix), do: (workorder_schedule_query(WorkorderSchedule,%{"asset_id" => equipment.id, "asset_type" => "E"}) |> Repo.all(prefix: prefix) |> length()) > 0
end

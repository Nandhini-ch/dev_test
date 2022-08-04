defmodule Inconn2Service.Util.DeleteManager do
  import Inconn2Service.Util.IndexQueries

  alias Inconn2Service.AssetConfig.{Site, Zone}
  alias Inconn2Service.Repo
  alias Inconn2Service.InventoryManagement.Store
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.AssetConfig.{Equipment, Location}
  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.CheckListConfig.{Check, CheckType}
  alias Inconn2Service.Workorder.WorkorderSchedule



  def has_employee_rosters?(%Site{} = site, prefix), do: (employee_rosters_query(EmployeeRoster,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_shift?(%Site{} = site, prefix), do: (shift_query(Shift,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_store?(%Site{} = site, prefix), do: (store_query(Store,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  #def has_site?(%Zone{} = zone, prefix), do: (site_query(Site,%{"zone_id" => zone.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_equipment?(%Site{} = site, prefix), do: (equipment_query(Equipment,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_equipment?(%Location{} = location, prefix), do: (equipment_query(Equipment,%{"location_id" => location.id}) |>Repo.all(prefix: prefix) |> length()) > 0

  def has_equipment?(%AssetCategory{} = asset_category, prefix) do
    descendant_asset_category_ids = HierarchyManager.descendants(asset_category) |> Enum.map(fn a -> a.id end)
    (equipment_query(Equipment,%{"asset_category_ids" => descendant_asset_category_ids}) |> Repo.all(prefix: prefix) |> length()) > 0
  end

  def has_descendants?(resource, prefix), do: (HierarchyManager.descendants(resource) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_location?(%Site{} = site, prefix), do: (location_query(Location,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_location?(%AssetCategory{} = asset_category, prefix), do: (location_query(Location,%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  #def has_location?(%Site{} = site, prefix), do: (location_query(Location,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workorder_template?(%AssetCategory{} = asset_category, prefix), do: (workorder_template_query(WorkorderTemplate,%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workorder_schedule?(%Location{} = location, prefix), do: (workorder_schedule_query(WorkorderSchedule,%{"asset_id" => location.id, "asset_type" => "L"}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_schedule?(%Equipment{} = equipment, prefix), do: (workorder_schedule_query(WorkorderSchedule,%{"asset_id" => equipment.id, "asset_type" => "E"}) |> Repo.all(prefix: prefix) |> length()) > 0


  def has_site?(%Zone{} = zone, prefix), do: (site_query(Site,%{"zone_id" => zone.id},prefix) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_check?(%CheckType{} = check_type, prefix), do: (check_query(Check,%{"check_type_id" => check_type.id}) |> Repo.all(prefix: prefix) |> length()) > 0
end

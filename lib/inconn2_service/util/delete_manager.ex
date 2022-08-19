defmodule Inconn2Service.Util.DeleteManager do
  import Inconn2Service.Util.IndexQueries

  alias Inconn2Service.AssetConfig.{Site, Zone}
  alias Inconn2Service.Repo
  alias Inconn2Service.InventoryManagement.Store
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.AssetConfig.{Equipment, Location}
  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.CheckListConfig.{Check, CheckType, CheckList}
  alias Inconn2Service.Workorder.{WorkorderSchedule, WorkorderTemplate}
  alias Inconn2Service.WorkOrderConfig.TaskList
  alias Inconn2Service.AssetConfig.Party
  alias Inconn2Service.Staff.{OrgUnit, Employee, User}
  alias Inconn2Service.ContractManagement.{Contract, Scope}
  alias Inconn2Service.WorkOrderConfig.MasterTaskType
  alias Inconn2Service.WorkOrderConfig.{Task, TaskTasklist, TaskList}
  alias Inconn2Service.Workorder.WorkorderTemplate

  def has_employee_rosters?(%Site{} = site, prefix), do: (employee_rosters_query(Repo.add_active_filter(EmployeeRoster),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_shift?(%Site{} = site, prefix), do: (shift_query(Repo.add_active_filter(Shift),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_store?(%Site{} = site, prefix), do: (store_query(Repo.add_active_filter(Store),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  #def has_site?(%Zone{} = zone, prefix), do: (site_query(Site,%{"zone_id" => zone.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_equipment?(%Site{} = site, prefix), do: (equipment_query(Repo.add_active_filter(Equipment),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_equipment?(%Location{} = location, prefix), do: (equipment_query(Repo.add_active_filter(Equipment),%{"location_id" => location.id}) |>Repo.all(prefix: prefix) |> length()) > 0

  def has_equipment?(%AssetCategory{} = asset_category, prefix) do
    # descendant_asset_category_ids = HierarchyManager.descendants(asset_category) |> Enum.map(fn a -> a.id end)
    (equipment_query(Repo.add_active_filter(Equipment),%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  end

  def has_descendants?(resource, prefix), do: (HierarchyManager.descendants(resource) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_location?(%Site{} = site, prefix), do: (location_query(Repo.add_active_filter(Location),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_location?(%AssetCategory{} = asset_category, prefix), do: (location_query(Repo.add_active_filter(Location),%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  #def has_location?(%Site{} = site, prefix), do: (location_query(Location,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workorder_template?(%AssetCategory{} = asset_category, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate),%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_template?(%CheckList{} = check_list, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate),%{"workpermit_check_list_id" => check_list.id, "loto_lock_check_list_id" => check_list.id, "loto_release_check_list_id" => check_list.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_template?(%TaskList{} = task_list, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate), %{"task_list_id" => task_list.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workorder_schedule?(%Location{} = location, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"asset_id" => location.id, "asset_type" => "L"}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_schedule?(%Equipment{} = equipment, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"asset_id" => equipment.id, "asset_type" => "E"}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_task_list?(%AssetCategory{} = asset_category, prefix), do: (task_list_query(Repo.add_active_filter(TaskList), %{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_site?(%Zone{} = zone, prefix), do: (site_query(Repo.add_active_filter(Site), %{"zone_id" => zone.id}, prefix) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_site?(%Party{} = party, prefix), do: (site_query(Repo.add_active_filter(Site), %{"party_id" => party.id}, prefix) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_check?(%CheckType{} = check_type, prefix), do: (check_query(Repo.add_active_filter(Check), %{"check_type_id" => check_type.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_check_list?(%Check{} = check, prefix), do: (check_list_query(Repo.add_active_filter(CheckList), %{"check_id" => check.id}) |> Repo.all(prefix: prefix) |> length()) > 0


  def has_contract?(%Party{} = party, prefix), do: (contract_query(Repo.add_active_filter(Contract), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_org_unit?(%Party{} = party, prefix), do: (org_unit_query(Repo.add_active_filter(OrgUnit), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_employee?(%Party{} = party, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_user?(%Party{} = party, prefix), do: (user_query(Repo.add_active_filter(User), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_scope?(%Contract{} = contract, prefix), do: (scope_query(Repo.add_active_filter(Scope), %{"contract_id" => contract.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_task?(%MasterTaskType{} = master_task_type, prefix), do: (task_query(Repo.add_active_filter(Task), %{"master_task_type_id" => master_task_type.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_task_tasklistt?(%Task{} = task, prefix), do: (task_tasklist_query((TaskTasklist), %{"task_id" => task.id}) |> Repo.all(prefix: prefix) |> length()) > 0

end

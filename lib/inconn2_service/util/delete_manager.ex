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
  alias Inconn2Service.Staff.{OrgUnit, Employee, User, Role}
  alias Inconn2Service.ContractManagement.{Contract, Scope}
  alias Inconn2Service.Settings.Shift
  # alias Inconn2Service.Ticket
  # alias Inconn2Service.Prompt.AlertNotificationConfig
  # alias Inconn2Service.InventoryManagement
  alias Inconn2Service.Assignment.EmployeeRoster
  alias Inconn2Service.Prompt.AlertNotificationConfig


  def has_employee_rosters?(%Site{} = site, prefix), do: (employee_rosters_query(Repo.add_active_filter(EmployeeRoster),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee_rosters?(%Shift{} = shift, prefix), do: (employee_rosters_query(Repo.add_active_filter(EmployeeRoster), %{"shift_id" => shift.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee_rosters?(%Employee{} = employee, prefix), do: (employee_rosters_query(Repo.add_active_filter(EmployeeRoster), %{"employee_id" => employee.id}) |> Repo.all(prefix: prefix) |> length()) > 0


  def has_shift?(%Site{} = site, prefix), do: (shift_query(Repo.add_active_filter(Shift),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_store?(%Site{} = site, prefix), do: (store_query(Repo.add_active_filter(Store),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_store?(%User{} = user, prefix), do: (store_query(Repo.add_active_filter(Store), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0
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

  def has_workorder_schedule?(%Location{} = location, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"asset_id" => location.id, "asset_type" => "L"}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_schedule?(%Equipment{} = equipment, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"asset_id" => equipment.id, "asset_type" => "E"}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_task_list?(%AssetCategory{} = asset_category, prefix), do: (task_list_query(Repo.add_active_filter(TaskList), %{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_site?(%Zone{} = zone, prefix), do: (site_query(Repo.add_active_filter(Site), %{"zone_id" => zone.id}, prefix) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_site?(%Party{} = party, prefix), do: (site_query(Repo.add_active_filter(Site), %{"party_id" => party.id}, prefix) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_check?(%CheckType{} = check_type, prefix), do: (check_query(Repo.add_active_filter(Check), %{"check_type_id" => check_type.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_contract?(%Party{} = party, prefix), do: (contract_query(Repo.add_active_filter(Contract), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_org_unit?(%Party{} = party, prefix), do: (org_unit_query(Repo.add_active_filter(OrgUnit), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_employee?(%Party{} = party, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee?(%OrgUnit{} = org_unit, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"org_unit_id" => org_unit.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee?(%User{} = user, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_user?(%Party{} = party, prefix), do: (user_query(Repo.add_active_filter(User), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_user?(%Employee{} = employee, prefix), do: (user_query(Repo.add_active_filter(User), %{"employee_id" => employee.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_user?(%Role{} = role, prefix), do: (user_query(Repo.add_active_filter(User), %{"role_id" => role.id}) |> Repo.all(prefix: prefix) |> length()) > 0


  def has_scope?(%Contract{} = contract, prefix), do: (scope_query(Repo.add_active_filter(Scope), %{"contract_id" => contract.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_reports_to?(%Employee{} = employee, prefix), do: (reports_to_query(Repo.add_active_filter(ReportsTo), %{"reports_to" => employee.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_alert_configuration?(%User{} = user, prefix), do: (alert_notification_configuration_query(Repo.add_active_filter(AlertNotificationConfig), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_category_helpdesk?(%User{} = user, prefix), do: (category_helpdesk_query(Repo.add_active_filter(CategoryHelpdesk), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0

end

defmodule Inconn2Service.Util.DeleteManager do
  import Inconn2Service.Util.IndexQueries

  alias Inconn2Service.Ticket.WorkRequest
  alias Inconn2Service.AssetConfig.{Site, Zone}
  alias Inconn2Service.Repo
  alias Inconn2Service.Settings.Shift
  alias Inconn2Service.InventoryManagement.Store
  alias Inconn2Service.Assignment.EmployeeRoster
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.AssetConfig.{Equipment, Location}
  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.CheckListConfig.{Check, CheckType, CheckList}
  alias Inconn2Service.Workorder.{WorkorderSchedule, WorkorderTemplate}
  alias Inconn2Service.WorkOrderConfig.TaskList
  alias Inconn2Service.AssetConfig.Party
  alias Inconn2Service.Staff.{OrgUnit, Employee, User, Role, Designation, TeamMember }
  alias Inconn2Service.ContractManagement.{Contract, Scope, ManpowerConfiguration}
  alias Inconn2Service.Settings.Shift
  alias Inconn2Service.Assignment.EmployeeRoster
  alias Inconn2Service.Prompt.AlertNotificationConfig
  alias Inconn2Service.Ticket.{WorkrequestCategory, WorkrequestSubcategory, CategoryHelpdesk}
  alias Inconn2Service.WorkOrderConfig.MasterTaskType
  alias Inconn2Service.WorkOrderConfig.{Task, TaskTasklist, TaskList}
  alias Inconn2Service.Workorder.WorkorderTemplate

  def has_employee_rosters?(%Site{} = site, prefix), do: (employee_rosters_query(Repo.add_active_filter(EmployeeRoster),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee_rosters?(%Shift{} = shift, prefix), do: (employee_rosters_query(Repo.add_active_filter(EmployeeRoster), %{"shift_id" => shift.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee_rosters?(%Employee{} = employee, prefix), do: (employee_rosters_query(Repo.add_active_filter(EmployeeRoster), %{"employee_id" => employee.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_shift?(%Site{} = site, prefix), do: (shift_query(Repo.add_active_filter(Shift),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_store?(%Site{} = site, prefix), do: (store_query(Repo.add_active_filter(Store),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_store?(%User{} = user, prefix), do: (store_query(Repo.add_active_filter(Store), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_site?(%Zone{} = zone, prefix), do: (site_query(Repo.add_active_filter(Site),%{"zone_id" => zone.id}, prefix) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_site?(%Party{} = party, prefix), do: (site_query(Repo.add_active_filter(Site), %{"party_id" => party.id}, prefix) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_equipment?(%Site{} = site, prefix), do: (equipment_query(Repo.add_active_filter(Equipment),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_equipment?(%Location{} = location, prefix), do: (equipment_query(Repo.add_active_filter(Equipment),%{"location_id" => location.id}) |>Repo.all(prefix: prefix) |> length()) > 0

  def has_equipment?(%AssetCategory{} = asset_category, prefix) do
    # descendant_asset_category_ids = HierarchyManager.descendants(asset_category) |> Enum.map(fn a -> a.id end)
    (equipment_query(Repo.add_active_filter(Equipment),%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  end

  def has_descendants?(resource, prefix), do: (HierarchyManager.descendants(resource) |> Repo.add_active_filter() |> Repo.all(prefix: prefix) |> length()) > 0

  def has_location?(%Site{} = site, prefix), do: (location_query(Repo.add_active_filter(Location),%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_location?(%AssetCategory{} = asset_category, prefix), do: (location_query(Repo.add_active_filter(Location),%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  #def has_location?(%Site{} = site, prefix), do: (location_query(Location,%{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workorder_template_ac?(%AssetCategory{} = asset_category, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate),%{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_template_workpermit_check_list_id?(%CheckList{} = check_list, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate),%{"workpermit_check_list_id" => check_list.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_template_precheck_list_id?(%CheckList{} = check_list, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate),%{"precheck_list_id" => check_list.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_template_loto_lock_check_list_id?(%CheckList{} = check_list, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate),%{"loto_lock_check_list_id" => check_list.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_template_loto_release_check_list_id?(%CheckList{} = check_list, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate),%{"loto_release_check_list_id" => check_list.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_template_task_list?(%TaskList{} = task_list, prefix), do: (workorder_template_query(Repo.add_active_filter(WorkorderTemplate), %{"task_list_id" => task_list.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workorder_schedule?(%Location{} = location, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"asset_id" => location.id, "asset_type" => "L"}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_schedule?(%Equipment{} = equipment, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"asset_id" => equipment.id, "asset_type" => "E"}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_schedule?(%WorkorderTemplate{} = workorder_template, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"workorder_template_id" => workorder_template.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_workorder_schedule?(%User{} = user, prefix), do: (workorder_schedule_query(Repo.add_active_filter(WorkorderSchedule),%{"workorder_approval_user_id" => user.id, "workorder_acknowledgement_user_id" => user.id, "workpermit_approval_user_id" => user.id, "loto_checker_user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_task_list?(%AssetCategory{} = asset_category, prefix), do: (task_list_query(Repo.add_active_filter(TaskList), %{"asset_category_id" => asset_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  # def has_site?(%Zone{} = zone, prefix), do: (site_query(Repo.add_active_filter(Site), %{"zone_id" => zone.id}, prefix) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_check?(%CheckType{} = check_type, prefix), do: (check_query(Repo.add_active_filter(Check), %{"check_type_id" => check_type.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_check_list?(%Check{} = check, prefix), do: (check_list_query(Repo.add_active_filter(CheckList), %{"check_id" => check.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_contract?(%Party{} = party, prefix), do: (contract_query(Repo.add_active_filter(Contract), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_org_unit?(%Party{} = party, prefix), do: (org_unit_query(Repo.add_active_filter(OrgUnit), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_employee?(%Party{} = party, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee?(%OrgUnit{} = org_unit, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"org_unit_id" => org_unit.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_employee?(%User{} = user, prefix), do: (employee_query_for_user(Repo.add_active_filter(Employee), user.employee_id) |> Repo.all(prefix: prefix) |> length()) > 0
  # def has_employee?(%User{} = user, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_employee?(%Designation{} = designation, prefix), do: (employee_query(Repo.add_active_filter(Employee), %{"designation_id" => designation.id}) |> Repo.all(prefix: prefix)) |> length() > 0

  def has_user?(%Party{} = party, prefix), do: (user_query(Repo.add_active_filter(User), %{"party_id" => party.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_user?(%Employee{} = employee, prefix), do: (user_query(Repo.add_active_filter(User), %{"employee_id" => employee.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_user?(%Role{} = role, prefix), do: (user_query(Repo.add_active_filter(User), %{"role_id" => role.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_scope?(%Contract{} = contract, prefix), do: (scope_query(Repo.add_active_filter(Scope), %{"contract_id" => contract.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_manpower_configuration?(%Contract{} = contract, prefix), do: (manpower_configuration_query(Repo.add_active_filter(ManpowerConfiguration), %{"contract_id" => contract.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_manpower_configuration?(%Site{} = site, prefix), do: (manpower_configuration_query(Repo.add_active_filter(ManpowerConfiguration), %{"site_id" => site.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_manpower_configuration?(%Shift{} = shift, prefix), do: (manpower_configuration_query(Repo.add_active_filter(ManpowerConfiguration), %{"shift_id" => shift.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_manpower_configuration?(%Designation{} = designation, prefix), do: (manpower_configuration_query(Repo.add_active_filter(ManpowerConfiguration), %{"designation_id" => designation.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_reports_to?(%Employee{} = employee, prefix), do: (reports_to_query(Repo.add_active_filter(Employee), %{"reports_to" => employee.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  # def has_alert_configuration?(%User{} = user, prefix), do: (alert_notification_configuration_query(Repo.add_active_filter(AlertNotificationConfig), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  def has_alert_configuration?(%User{} = _user, _prefix), do: false

  def has_category_helpdesk?(%User{} = user, prefix), do: (category_helpdesk_query(Repo.add_active_filter(CategoryHelpdesk), %{"user_id" => user.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_workrequest_subcategory?(%WorkrequestCategory{} = workrequest_category, prefix), do: (workrequest_subcategory_query(Repo.add_active_filter(WorkrequestSubcategory), %{"workrequest_category_id" => workrequest_category.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_work_request?(%WorkrequestSubcategory{} = workrequest_subcategory, prefix), do: (work_request_query((WorkRequest), %{"workrequest_subcategory_id" => workrequest_subcategory.id, "not_statuses" => ["CL", "CS"]}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_task?(%MasterTaskType{} = master_task_type, prefix), do: (task_query(Repo.add_active_filter(Task), %{"master_task_type_id" => master_task_type.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_task_tasklistt?(%Task{} = task, prefix), do: (task_tasklist_query(TaskTasklist,%{"task_id" => task.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  def has_team_member(%Employee{} = employee, prefix), do: (team_member_query((Repo.add_active_filter(TeamMember)), %{"employee_id" => employee.id}) |> Repo.all(prefix: prefix) |> length()) > 0

end

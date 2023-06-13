defmodule Inconn2Service.Util.IndexQueries do
  import Ecto.Query, warn: false

  alias Inconn2Service.AssetConfig

  def site_query(query, query_params, prefix) do
    Enum.reduce(query_params, query, fn
      {"zone_id", nil}, query ->
          query
      {"zone_id", zone_id}, query ->
          zone_ids = AssetConfig.get_zone_subtree_ids(zone_id, prefix)
          from q in query, where: q.zone_id in ^zone_ids
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      _, query -> from q in query, where: q.active
    end)
  end

  def employee_rosters_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      {"shift_id", shift_id}, query -> from q in query, where: q.shift_id == ^shift_id
      {"employee_id", employee_id}, query -> from q in query, where: q.employee_id == ^employee_id
      _, query -> from q in query, where: q.active
    end)
  end

  def shift_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      _, query -> from q in query, where: q.active
    end)
  end

  def store_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      {"user_id", user_id}, query -> from q in query, where: q.user_id == ^user_id
      _, query -> from q in query, where: q.active
    end)
  end

  def equipment_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    {"site_ids", site_ids}, query -> from q in query, where: q.site_id == ^site_ids
    {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
    {"asset_category_ids", asset_category_ids}, query -> from q in query, where: q.asset_category_id in ^asset_category_ids
    {"location_ids", location_ids}, query -> from q in query, where: q.location_id in ^location_ids
    {"location_id", location_id}, query -> from q in query, where: q.location_id == ^location_id
    {"status", status}, query -> from q in query, where: q.status == ^status
    {"criticality", 0}, query -> query
    {"criticality", criticality}, query -> from q in query, where: q.criticality == ^criticality
    _, query -> from q in query, where: q.active
    end)
  end

  def location_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      {"site_ids", site_ids}, query -> from q in query, where: q.site_id == ^site_ids
      {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
      {"asset_category_ids", asset_category_ids}, query -> from q in query, where: q.asset_category_id in ^asset_category_ids
      {"location_ids", location_ids}, query -> from q in query, where: q.location_id in ^location_ids
      _, query -> from q in query, where: q.active
    end)
  end

  def check_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"check_type_id", check_type_id}, query -> from q in query, where: q.check_type_id == ^check_type_id
      _, query -> from q in query, where: q.active
    end)
  end

  def check_list_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"check_id", check_id}, query -> from q in query, where: ^check_id in q.check_ids
      _, query -> from q in query, where: q.active
    end)
  end


  def workorder_template_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
    {"workpermit_check_list_id", workpermit_check_list_id}, query -> from q in query, where: q.workpermit_check_list_id == ^workpermit_check_list_id
    {"loto_lock_check_list_id", loto_lock_check_list_id}, query -> from q in query, where: q.loto_lock_check_list_id == ^loto_lock_check_list_id
    {"loto_release_check_list_id", loto_release_check_list_id}, query -> from q in query, where: q.loto_release_check_list_id == ^loto_release_check_list_id
    {"precheck_list_id", precheck_list_id}, query -> from q in query, where: q.precheck_list_id == ^precheck_list_id
    {"task_list_id", task_list_id}, query -> from q in query, where: q.task_list_id == ^task_list_id
    _, query -> from q in query, where: q.active end)
  end

  def workorder_schedule_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"asset_id", asset_id}, query -> from q in query, where: q.asset_id == ^asset_id
      {"asset_type", asset_type}, query -> from q in query, where: q.asset_type == ^asset_type
      {"workorder_template_id", workorder_template_id}, query -> from q in query, where: q.workorder_template_id == ^workorder_template_id
      {"workorder_approval_user_id", workorder_approval_user_id}, query -> from q in query, where: q.workorder_approval_user_id == ^workorder_approval_user_id
      {"workorder_acknowledgement_user_id", workorder_acknowledgement_user_id}, query -> from q in query, where: q.workorder_acknowledgement_user_id == ^workorder_acknowledgement_user_id
      {"workpermit_approval_user_id", workpermit_approval_user_id}, query -> from q in query, where: ^workpermit_approval_user_id in q.workpermit_approval_user_ids
      {"loto_checker_user_id", loto_checker_user_id}, query -> from q in query, where: q.loto_checker_user_id == ^loto_checker_user_id

      _, query -> from q in query, where: q.active end)
  end

  def task_list_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
      _, query -> from q in query, where: q.active end)
  end

  def contract_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query ->from q in query, where: q.party_id == ^party_id
      _, query -> from q in query, where: q.active end)
  end

  def scope_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    {"contract_id", contract_id}, query -> from q in query, where: q.contract_id == ^contract_id
    _, query -> from q in query, where: q.active end)
  end

  def sla_query(query, contract_id) do
    Enum.reduce(contract_id, query, fn
    {"contract_id", contract_id}, query -> from q in query, where: q.contract_id == ^contract_id
    _, query -> from q in query, where: q.active end)
  end

  def party_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"type", "sp"}, query -> from q in query, where: q.party_type == "SP"
      {"type", "ao"}, query -> from q in query, where: q.party_type == "AO"
      _, query -> from q in query, where: q.active
    end)
  end

  def org_unit_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      _, query -> from q in query, where: q.active
    end)
  end

  def roster_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"shift_id", shift_id}, query -> from q in query, where: q.shift_id == ^shift_id
      _, query -> from q in query, where: q.active
    end)
  end

  def employee_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"id", id}, query -> from q in query, where: q.id == ^id
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      {"org_unit_id", org_unit_id }, query -> from q in query, where: q.org_unit_id == ^org_unit_id
      # {"user_id", user_id}, query -> from q in query, where: q.user_id == ^user_id
      {"designation_id", designation_id}, query -> from q in query, where: q.designation_id == ^designation_id
      _, query -> from q in query, where: q.active
    end)
  end

  def employee_query_for_user(query, nil), do: from q in query, where: q.id == 0
  def employee_query_for_user(query, id), do: from q in query, where: q.id == ^id

  def user_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      {"employee_id", employee_id}, query -> from q in query, where: q.employee_id == ^employee_id
      {"role_id", role_id}, query -> from q in query, where: q.role_id == ^role_id
      _, query -> from q in query, where: q.active
    end)
  end

  def reports_to_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"reports_to", reports_to}, query -> from q in query, where: q.reports_to == ^reports_to
      _, query -> from q in query, where: q.active
    end)
  end

  def task_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"master_task_type_id", master_task_type_id}, query -> from q in query, where: q.master_task_type_id == ^master_task_type_id
      _, query -> from q in query, where: q.active
    end)
  end

  def alert_notification_configuration_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"user_id", user_id}, query -> from q in query, where: ^user_id in q.addressed_to_user_ids or ^user_id in q.escalated_to_user_ids
      _, query -> from q in query, where: q.active
    end)
  end

  def task_tasklist_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"task_id", task_id}, query -> from q in query, where: q.task_id == ^task_id
      _, query -> query
    end)
  end

  def checklist_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"type", type}, query -> from q in query, where: q.type == ^type
      _, query -> from q in query, where: q.active
    end)
  end

  def work_request_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"workrequest_category_id", 0}, query -> query
      {"priority", ""}, query -> query
      {"workrequest_category_ids", []}, query -> query
      {"workrequest_category_id", workrequest_category_id}, query -> from q in query, where: q.workrequest_category_id == ^workrequest_category_id
      {"workrequest_category_ids", workrequest_category_ids}, query -> from q in query, where: q.workrequest_category_ids == ^workrequest_category_ids
      {"workrequest_subcategory_id", workrequest_subcategory_id}, query -> from q in query, where: q.workrequest_subcategory_id == ^workrequest_subcategory_id
      {"priority", priority}, query -> from q in query, where: q.priority == ^priority
      {"not_statuses", not_statuses}, query -> from q in query, where: q.status not in ^not_statuses
      _, query -> query
    end)
  end

  def category_helpdesk_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"user_id", user_id}, query -> from q in query, where: q.user_id == ^user_id
      _, query -> from q in query, where: q.active
    end)
  end

  def workrequest_subcategory_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"workrequest_category_id", workrequest_category_id}, query -> from q in query, where: q.workrequest_category_id == ^workrequest_category_id
      _, query -> from q in query, where: q.active
    end)
  end

  def reassign_reschedule_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"request_for", request_for}, query -> from q in query, where: q.request_for == ^request_for
      _, query -> query
    end)
  end

  def inventory_item_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"item_type", "spare"}, query -> from q in query, where: q.item_type == "Spare"
      {"item_type", "tool"}, query -> from q in query, where: q.item_type == "Tool"
      {"item_type", "part"}, query -> from q in query, where: q.item_type == "Part"
      {"item_type", "consumable"}, query -> from q in query, where: q.item_type == "Consumable"
      {"item_type", "measuring_instrument"}, query -> from q in query, where: q.item_type == "Measuring Instrument"
      {"asset_category_id", asset_category_id}, query -> from q in query, where: ^asset_category_id in q.asset_category_ids
      _, query -> query
    end)
  end

  def transactions_query(query, query_params) do
    Enum.reduce(query_params, query, fn
       {"item_id", item_id}, query -> from q in query, where: q.inventory_item_id == ^item_id
       {"unit_of_measurement_id", uom_id}, query -> from q in query, where: q.unit_of_measurement_id == ^uom_id
       {"supplier_id", supplier_id}, query -> from q in query, where: q.inventory_supplier_id == ^supplier_id
       {"store_id", store_id}, query -> from q in query, where: q.store_id == ^store_id
       {"dc_no", dc_no}, query -> from q in query, where: q.dc_no == ^dc_no
       {"reference_no", reference_no}, query -> from q in query, where: q.transaction_reference == ^reference_no
       {"type", type}, query -> from q in query, where: q.transaction_type == ^type
       {"is_approval_required", "true"}, query -> from q in query, where: q.is_approval_required
       {"is_approval_required", "false"}, query -> from q in query, where: q.is_approval_required == false
       _ , query -> query
    end)
  end

  def manpower_configuration_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"contract_id", contract_id}, query -> from q in query, where: q.contract_id == ^contract_id
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      {"designation_id", designation_id}, query -> from q in query, where: q.designation_id == ^designation_id
      {"shift_id", shift_id}, query -> from q in query, where: q.shift_id == ^shift_id
      _, query -> query
    end)
  end

  def attendance_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"employee_id", employee_id}, query -> from q in query, where: q.employee_id == ^employee_id
      {"employee_ids", employee_ids}, query -> from q in query, where: q.employee_id in ^employee_ids
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      {"from_date", from_date}, query -> from q in query, where: q.in_time >= ^from_date
      {"to_date", to_date}, query -> from q in query, where: q.in_time <= ^to_date
      _ , query -> query
    end)
  end

  def team_member_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"employee_id", employee_id}, query -> from q in query, where: q.employee_id == ^employee_id
      {"employee_ids", employee_ids}, query -> from q in query, where: q.employee_id in ^employee_ids
      {"team_id", team_id}, query -> from q in query, where: q.team_id == ^team_id
      _ , query -> query
    end)
  end

  def saved_dashboard_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"widget_code", widget_code}, query -> from q in query, where: q.widget_code == ^widget_code
      {"user_id", user_id}, query -> from q in query, where: q.user_id == ^user_id
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      _, query -> query
    end)
  end
end

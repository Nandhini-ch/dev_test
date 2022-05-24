defmodule Inconn2ServiceWeb.WorkOrderView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkOrderView, LocationView, EquipmentView, WorkRequestView}
  alias Inconn2ServiceWeb.{UserView, WorkorderTemplateView}
  alias Inconn2ServiceWeb.{SiteView, EmployeeView, WorkorderTaskView}

  def render("index.json", %{work_orders: work_orders}) do
    %{data: render_many(work_orders, WorkOrderView, "work_order.json")}
  end

  def render("show.json", %{work_order: work_order}) do
    %{data: render_one(work_order, WorkOrderView, "work_order.json")}
  end

  def render("mobile_index.json", %{work_orders: work_orders}) do
    %{data: render_many(work_orders, WorkOrderView, "mobile_work_order.json")}
  end

  def render("mobile_index_test.json", %{work_orders: work_orders}) do
    %{data: render_many(work_orders, WorkOrderView, "mobile_test.json")}
  end

  def render("flutter_mobile.json", %{work_orders: work_orders}) do
    %{data: render_many(work_orders, WorkOrderView, "flutter.json")}
  end

  def render("mobile_show.json", %{work_order: work_order}) do
    %{data: render_one(work_order, WorkOrderView, "mobile_work_order.json")}
  end

  def render("flutter.json", %{work_order: work_order}) do
    workorder_tasks = if is_nil(work_order.workorder_tasks), do: nil, else: render_many(work_order.workorder_tasks, WorkorderTaskView, "workorder_task_with_task.json")
    %{id: work_order.id ,
      site_id: work_order.site_id,
      site_name: work_order.site_name,
      asset_id: work_order.asset_id,
      asset_name: work_order.asset_name,
      asset_code: work_order.asset_code,
      qr_code: work_order.qr_code,
      # work_request: render_one(work_order.work_request, WorkRequestView, "work_request_mobile.json"),
      type: work_order.type,
      scheduled_date: work_order.scheduled_date,
      scheduled_time: work_order.scheduled_time,
      start_date: work_order.start_date,
      start_time: work_order.start_time,
      user: (if is_nil(work_order.user), do: nil, else: work_order.user.username),
      # employee: work_order.employee,
      workorder_tasks: workorder_tasks,
      employee: (if is_nil(work_order.employee), do: nil, else: work_order.employee.first_name),
      completed_date: work_order.completed_date,
      completed_time: work_order.completed_time,
      status: work_order.status,
      is_workorder_approval_required: work_order.is_workorder_approval_required,
      is_loto_required: work_order.is_loto_required,
      is_workorder_acknowledgement_required: work_order.is_workorder_acknowledgement_required,
      is_workpermit_required: work_order.is_workpermit_required,
      pause_resume_times: work_order.pause_resume_times
    }
  end

  def render("mobile_test.json", %{work_order: work_order}) do
    workorder_tasks = if is_nil(work_order.workorder_tasks), do: nil, else: render_many(work_order.workorder_tasks, WorkorderTaskView, "workorder_task_with_task.json")

    asset =
      case work_order.workorder_template.asset_type do
        "E" -> render_one(work_order.asset, EquipmentView, "equipment.json")
        "L" -> render_one(work_order.asset, LocationView, "location.json")
      end

    %{id: work_order.id,
      site_id: work_order.site_id,
      site: render_one(work_order.site, SiteView, "site.json"),
      workorder_tasks: workorder_tasks,
      # work_request: render_one(work_order.work_request, WorkRequestView, "work_request_mobile.json"),
      # asset: render_one(work_order.asset, WorkOrderView, "asset.json"),
      asset: asset,
      user_id: work_order.user_id,
      user: render_one(work_order.user, UserView, "user_mobile.json"),
      employee: render_one(work_order.employee, EmployeeView, "employee_without_org_unit.json"),
      type: work_order.type,
      created_date: work_order.created_date,
      created_time: work_order.created_time,
      assigned_date: work_order.assigned_date,
      assigned_time: work_order.assigned_time,
      scheduled_date: work_order.scheduled_date,
      scheduled_time: work_order.scheduled_time,
      start_date: work_order.start_date,
      start_time: work_order.start_time,
      completed_date: work_order.completed_date,
      completed_time: work_order.completed_time,
      status: work_order.status,
      is_deactivated: work_order.is_deactivated,
      deactivated_date_time: work_order.deactivated_date_time,
      workorder_template_id: work_order.workorder_template_id,
      workorder_template: render_one(work_order.workorder_template, WorkorderTemplateView, "workorder_template.json"),
      workorder_schedule_id: work_order.workorder_schedule_id,
      # workorder_schedule: render_one(work_order.workorder_schedule, WorkorderScheduleView, "workorder_schedule_mobile.json"),
      work_request_id: work_order.work_request_id,
      pause_resume_times: work_order.pause_resume_times}
  end


  def render("permit_response.json", %{response: response}) do
    %{data: %{result: response.result, message: response.message}}
  end

  def render("next_step.json", %{response: response}) do
    %{data: response.next_step}
  end

  def render("enable_start.json", %{response: response}) do
    %{data: response}
  end

  def render("mobile_work_order.json", %{work_order: work_order}) do
    IO.inspect(work_order)
    asset =
      case work_order.workorder_template.asset_type do
        "E" -> render_one(work_order.asset, EquipmentView, "equipment.json")
        "L" -> render_one(work_order.asset, LocationView, "location.json")
      end
    %{id: work_order.id,
      site_id: work_order.site_id,
      site: render_one(work_order.site, SiteView, "site.json"),
      asset_id: work_order.asset_id,
      asset: asset,
      asset_qr_code: work_order.asset_qr_code,
      workorder_tasks: render_many(work_order.workorder_tasks, WorkorderTaskView, "workorder_task_with_task.json"),
      # work_request: render_one(work_order.work_request, WorkRequestView, "work_request.json"),
      # asset: render_one(work_order.asset, WorkOrderView, "asset.json"),
      user_id: work_order.user_id,
      # user: render_one(work_order.user, UserView, "user_mobile.json"),
      # employee: (if is_nil(work_order.employee), do:  nil, else: render_one(work_order.employee, EmployeeView, "employee_without_org_unit.json")),
      type: work_order.type,
      created_date: work_order.created_date,
      created_time: work_order.created_time,
      assigned_date: work_order.assigned_date,
      assigned_time: work_order.assigned_time,
      scheduled_date: work_order.scheduled_date,
      scheduled_time: work_order.scheduled_time,
      start_date: work_order.start_date,
      start_time: work_order.start_time,
      completed_date: work_order.completed_date,
      completed_time: work_order.completed_time,
      status: work_order.status,
      is_deactivated: work_order.is_deactivated,
      deactivated_date_time: work_order.deactivated_date_time,
      workorder_template_id: work_order.workorder_template_id,
      workorder_template: render_one(work_order.workorder_template, WorkorderTemplateView, "workorder_template.json"),
      workorder_schedule_id: work_order.workorder_schedule_id,
      # workorder_schedule: render_one(work_order.workorder_schedule, WorkorderScheduleView, "workorder_schedule_mobile.json"),
      work_request_id: work_order.work_request_id,
      pause_resume_times: work_order.pause_resume_times
      # workpermit_checks: render_many(work_order.workpermit_checks, WorkorderCheckView, "workorder_check.json"),
      # is_workorder_approval_required: work_order.is_workorder_approval_required,
      # workorder_approval_user_id: work_order.workorder_approval_user_id,
      # is_workpermit_required: work_order.is_workpermit_required,
      # workpermit_approval_user_ids: work_order.workpermit_approval_user_ids,
      # workpermit_obtained_from_user_ids: work_order.workpermit_obtained_from_user_ids,
      # loto_required: work_order.loto_required,
      # loto_checks: render_many(work_order.loto_checks, WorkorderCheckView, "workorder_check_with_check.json"),
      # loto_approval_from_user_id: work_order.loto_approval_from_user_id,
      # pre_check_required: work_order.pre_check_required,
      # pre_checks: render_many(work_order.pre_checks, WorkorderCheckView, "workorder_check_with_check.json"),
      # precheck_completed: work_order.precheck_completed
    }
  end


  def render("work_order.json", %{work_order: work_order}) do
    %{id: work_order.id,
      site_id: work_order.site_id,
      asset_id: work_order.asset_id,
      asset_name: work_order.asset_name,
      asset_type: work_order.asset_type,
      user_id: work_order.user_id,
      user: render_one(work_order.user, UserView, "user_without_org_unit.json"),
      is_self_assigned: work_order.is_self_assigned,
      type: work_order.type,
      created_date: work_order.created_date,
      created_time: work_order.created_time,
      assigned_date: work_order.assigned_date,
      assigned_time: work_order.assigned_time,
      scheduled_date: work_order.scheduled_date,
      scheduled_time: work_order.scheduled_time,
      start_date: work_order.start_date,
      start_time: work_order.start_time,
      completed_date: work_order.completed_date,
      completed_time: work_order.completed_time,
      status: work_order.status,
      is_workorder_approval_required: work_order.is_workorder_approval_required,
      workorder_approval_user_id: work_order.workorder_approval_user_id,
      is_workpermit_required: work_order.is_workpermit_required,
      workpermit_approval_user_ids: work_order.workpermit_approval_user_ids,
      workpermit_obtained_from_user_ids: work_order.workpermit_obtained_from_user_ids,
      is_workorder_acknowledgement_required: work_order.is_workorder_acknowledgement_required,
      workorder_acknowledgement_user_id: work_order.workorder_acknowledgement_user_id,
      workorder_template_id: work_order.workorder_template_id,
      workorder_schedule_id: work_order.workorder_schedule_id,
      work_request_id: work_order.work_request_id,
      is_loto_required: work_order.is_loto_required,
      # loto_approval_from_user_id: work_order.loto_approval_from_user_id,
      loto_checker_user_id: work_order.loto_checker_user_id,
      # is_loto_obtained: work_order.is_loto_obtained,
      pre_check_required: work_order.pre_check_required,
      precheck_completed: work_order.precheck_completed,
      is_deactivated: work_order.is_deactivated,
      deactivated_date_time: work_order.deactivated_date_time,
      overdue: work_order.overdue,
      pause_resume_times: work_order.pause_resume_times}
  end

  def render("asset.json", %{asset: asset, asset_type: asset_type}) do
    case asset_type do
      "L" -> %{data: render_one(asset, LocationView, "location.json")}
      "E" -> %{data: render_one(asset, EquipmentView, "equipment.json")}
    end
  end
end

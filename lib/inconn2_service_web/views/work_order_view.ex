defmodule Inconn2ServiceWeb.WorkOrderView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkOrderView, LocationView, EquipmentView}

  def render("index.json", %{work_orders: work_orders}) do
    %{data: render_many(work_orders, WorkOrderView, "work_order.json")}
  end

  def render("show.json", %{work_order: work_order}) do
    %{data: render_one(work_order, WorkOrderView, "work_order.json")}
  end

  def render("work_order.json", %{work_order: work_order}) do
    %{id: work_order.id,
      site_id: work_order.site_id,
      asset_id: work_order.asset_id,
      asset_name: work_order.asset_name,
      asset_type: work_order.asset_type,
      user_id: work_order.user_id,
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
      workorder_template_id: work_order.workorder_template_id,
      workorder_schedule_id: work_order.workorder_schedule_id,
      work_request_id: work_order.work_request_id,
      workpermit_required: work_order.workpermit_required,
      workpermit_required_from: work_order.workpermit_required_from,
      workpermit_obtained: work_order.workpermit_obtained,
      loto_required: work_order.loto_required,
      loto_approval_from_user_id: work_order.loto_approval_from_user_id,
      is_loto_obtained: work_order.is_loto_obtained,
      pre_check_required: work_order.pre_check_required,
      precheck_completed: work_order.precheck_completed,
      overdue: work_order.overdue}
  end

  def render("asset.json", %{asset: asset, asset_type: asset_type}) do
    case asset_type do
      "L" -> %{data: render_one(asset, LocationView, "location.json")}
      "E" -> %{data: render_one(asset, EquipmentView, "equipment.json")}
    end
  end
end

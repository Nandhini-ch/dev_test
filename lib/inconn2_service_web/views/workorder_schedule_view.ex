defmodule Inconn2ServiceWeb.WorkorderScheduleView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderScheduleView

  def render("index.json", %{workorder_schedules: workorder_schedules}) do
    %{data: render_many(workorder_schedules, WorkorderScheduleView, "workorder_schedule.json")}
  end

  def render("show.json", %{workorder_schedule: workorder_schedule}) do
    %{data: render_one(workorder_schedule, WorkorderScheduleView, "workorder_schedule.json")}
  end

  def render("workorder_schedule_mobile.json", %{workorder_schedule: workorder_schedule}) do
    %{id: workorder_schedule.id,
      # site_name: workorder_schedule.site.name,
      # asset_name: workorder_schedule.asset.name,
      asset_id: workorder_schedule.asset_id,
      asset_type: workorder_schedule.asset_type,
      workorder_template_id: workorder_schedule.workorder_template_id,
        asset_category_id: workorder_schedule.workorder_template.asset_category_id,
        name: workorder_schedule.workorder_template.name,
        task_list_id: workorder_schedule.workorder_template.task_list_id,
        tasks: workorder_schedule.workorder_template.tasks,
        estimated_time: workorder_schedule.workorder_template.estimated_time,
        scheduled: workorder_schedule.workorder_template.scheduled,
        repeat_every: workorder_schedule.workorder_template.repeat_every,
        repeat_unit: workorder_schedule.workorder_template.repeat_unit,
        applicable_start: workorder_schedule.workorder_template.applicable_start,
        applicable_end: workorder_schedule.workorder_template.applicable_end,
        time_start: workorder_schedule.workorder_template.time_start,
        time_end: workorder_schedule.workorder_template.time_end,
        workpermit_required: workorder_schedule.workorder_template.is_workpermit_required,
        workpermit_check_list_id: workorder_schedule.workorder_template.workpermit_check_list_id,
        loto_required: workorder_schedule.workorder_template.is_loto_required,
        loto_lock_check_list_id: workorder_schedule.workorder_template.loto_lock_check_list_id,
        loto_release_check_list_id: workorder_schedule.workorder_template.loto_release_check_list_id,
      holidays: workorder_schedule.holidays,
      first_occurrence_date: workorder_schedule.first_occurrence_date,
      first_occurrence_time: workorder_schedule.first_occurrence_time,
      next_occurrence_date: workorder_schedule.next_occurrence_date,
      next_occurrence_time: workorder_schedule.next_occurrence_time}
  end

  def render("workorder_schedule.json", %{workorder_schedule: workorder_schedule}) do
    %{id: workorder_schedule.id,
      site_name: workorder_schedule.site.name,
      asset_name: workorder_schedule.asset.name,
      asset_id: workorder_schedule.asset_id,
      asset_type: workorder_schedule.asset_type,
      workorder_template_id: workorder_schedule.workorder_template_id,
        asset_category_id: workorder_schedule.workorder_template.asset_category_id,
        name: workorder_schedule.workorder_template.name,
        task_list_id: workorder_schedule.workorder_template.task_list_id,
        tasks: workorder_schedule.workorder_template.tasks,
        estimated_time: workorder_schedule.workorder_template.estimated_time,
        scheduled: workorder_schedule.workorder_template.scheduled,
        repeat_every: workorder_schedule.workorder_template.repeat_every,
        repeat_unit: workorder_schedule.workorder_template.repeat_unit,
        applicable_start: workorder_schedule.workorder_template.applicable_start,
        applicable_end: workorder_schedule.workorder_template.applicable_end,
        time_start: workorder_schedule.workorder_template.time_start,
        time_end: workorder_schedule.workorder_template.time_end,
        workpermit_required: workorder_schedule.workorder_template.is_workpermit_required,
        workpermit_check_list_id: workorder_schedule.workorder_template.workpermit_check_list_id,
        loto_required: workorder_schedule.workorder_template.is_loto_required,
        loto_lock_check_list_id: workorder_schedule.workorder_template.loto_lock_check_list_id,
        loto_release_check_list_id: workorder_schedule.workorder_template.loto_release_check_list_id,
      holidays: workorder_schedule.holidays,
      first_occurrence_date: workorder_schedule.first_occurrence_date,
      first_occurrence_time: workorder_schedule.first_occurrence_time,
      next_occurrence_date: workorder_schedule.next_occurrence_date,
      next_occurrence_time: workorder_schedule.next_occurrence_time,
      workorder_approval_user_id: workorder_schedule.workorder_approval_user_id,
      workpermit_approval_user_ids: workorder_schedule.workpermit_approval_user_ids,
      workorder_acknowledgement_user_id: workorder_schedule.workorder_acknowledgement_user_id
    }
  end
end

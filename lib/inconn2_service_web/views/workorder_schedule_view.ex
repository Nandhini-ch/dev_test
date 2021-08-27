defmodule Inconn2ServiceWeb.WorkorderScheduleView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderScheduleView

  def render("index.json", %{workorder_schedules: workorder_schedules}) do
    %{data: render_many(workorder_schedules, WorkorderScheduleView, "workorder_schedule.json")}
  end

  def render("show.json", %{workorder_schedule: workorder_schedule}) do
    %{data: render_one(workorder_schedule, WorkorderScheduleView, "workorder_schedule.json")}
  end

  def render("workorder_schedule.json", %{workorder_schedule: workorder_schedule}) do
    %{id: workorder_schedule.id,
      asset_id: workorder_schedule.asset_id,
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
      config: workorder_schedule.config,
      next_occurance: workorder_schedule.next_occurance}
  end
end

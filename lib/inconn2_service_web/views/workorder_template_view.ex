defmodule Inconn2ServiceWeb.WorkorderTemplateView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderTemplateView

  def render("index.json", %{workorder_templates: workorder_templates}) do
    %{data: render_many(workorder_templates, WorkorderTemplateView, "workorder_template.json")}
  end

  def render("show.json", %{workorder_template: workorder_template}) do
    %{data: render_one(workorder_template, WorkorderTemplateView, "workorder_template.json")}
  end

  def render("workorder_template.json", %{workorder_template: workorder_template}) do
    %{
      id: workorder_template.id,
      asset_category_id: workorder_template.asset_category_id,
      asset_type: workorder_template.asset_type,
      name: workorder_template.name,
      task_list_id: workorder_template.task_list_id,
      tasks: workorder_template.tasks,
      estimated_time: workorder_template.estimated_time,
      scheduled: workorder_template.scheduled,
      repeat_every: workorder_template.repeat_every,
      repeat_unit: workorder_template.repeat_unit,
      applicable_start: workorder_template.applicable_start,
      applicable_end: workorder_template.applicable_end,
      time_start: workorder_template.time_start,
      time_end: workorder_template.time_end,
      create_new: workorder_template.create_new,
      max_times: workorder_template.max_times,
      tools: workorder_template.tools,
      spares: workorder_template.spares,
      consumables: workorder_template.consumables,
      workorder_prior_time: workorder_template.workorder_prior_time,
      is_workorder_approval_required: workorder_template.is_workorder_approval_required,
      is_workpermit_required: workorder_template.is_workpermit_required,
      is_workorder_acknowledgement_required: workorder_template.is_workorder_acknowledgement_required,
      workpermit_check_list_id: workorder_template.workpermit_check_list_id,
      is_loto_required: workorder_template.is_loto_required,
      loto_lock_check_list_id: workorder_template.loto_lock_check_list_id,
      loto_release_check_list_id: workorder_template.loto_release_check_list_id
    }
  end
end

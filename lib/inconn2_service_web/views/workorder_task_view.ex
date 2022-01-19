defmodule Inconn2ServiceWeb.WorkorderTaskView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkorderTaskView, TaskView}

  def render("index.json", %{workorder_tasks: workorder_tasks}) do
    %{data: render_many(workorder_tasks, WorkorderTaskView, "workorder_task.json")}
  end

  def render("show.json", %{workorder_task: workorder_task}) do
    %{data: render_one(workorder_task, WorkorderTaskView, "workorder_task.json")}
  end

  def render("group_update", %{workorder_task_details: workorder_task_details}) do
    %{
      success_count: workorder_task_details.success_count,
      error_count: workorder_task_details.error_count,
      failure_results: workorder_task_details.failure_results,
    }
  end

  def render("workorder_task_with_task.json", %{workorder_task: workorder_task}) do
    %{id: workorder_task.id,
      task_id: workorder_task.task_id,
      sequence: workorder_task.sequence,
      work_order_id: workorder_task.work_order_id,
      response: workorder_task.response,
      remarks: workorder_task.remarks,
      task: render_one(workorder_task.task, TaskView, "task.json"),
      expected_start_time: workorder_task.expected_start_time,
      expected_end_time: workorder_task.expected_end_time,
      actual_start_time: workorder_task.actual_start_time,
      actual_end_time: workorder_task.actual_end_time}
  end

  def render("workorder_task.json", %{workorder_task: workorder_task}) do
    %{id: workorder_task.id,
      task_id: workorder_task.task_id,
      sequence: workorder_task.sequence,
      work_order_id: workorder_task.work_order_id,
      response: workorder_task.response,
      remarks: workorder_task.remarks,
      expected_start_time: workorder_task.expected_start_time,
      expected_end_time: workorder_task.expected_end_time,
      actual_start_time: workorder_task.actual_start_time,
      actual_end_time: workorder_task.actual_end_time}
  end
end

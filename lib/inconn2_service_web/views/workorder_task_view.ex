defmodule Inconn2ServiceWeb.WorkorderTaskView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderTaskView

  def render("index.json", %{workorder_tasks: workorder_tasks}) do
    %{data: render_many(workorder_tasks, WorkorderTaskView, "workorder_task.json")}
  end

  def render("show.json", %{workorder_task: workorder_task}) do
    %{data: render_one(workorder_task, WorkorderTaskView, "workorder_task.json")}
  end

  def render("workorder_task.json", %{workorder_task: workorder_task}) do
    %{id: workorder_task.id,
      task_id: workorder_task.task_id,
      sequence: workorder_task.sequence,
      work_order_id: workorder_task.work_order_id,
      response: workorder_task.response}
  end
end

defmodule Inconn2ServiceWeb.TaskView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.TaskView

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{id: task.id,
      label: task.label,
      config: task.config,
      task_type: task.task_type,
      estimated_time: task.estimated_time}
  end
end

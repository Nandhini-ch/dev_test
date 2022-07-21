defmodule Inconn2ServiceWeb.TaskListView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.TaskListView

  def render("index.json", %{task_lists: task_lists}) do
    %{data: render_many(task_lists, TaskListView, "task_list.json")}
  end

  def render("show.json", %{task_list: task_list}) do
    %{data: render_one(task_list, TaskListView, "task_list.json")}
  end

  def render("index_tasks.json", %{task_tasklists: task_tasklists}) do
    %{data: render_many(task_tasklists, TaskListView, "task_with_sequence.json")}
  end

  def render("task_list.json", %{task_list: task_list}) do
    %{id: task_list.id,
      name: task_list.name,
      task_ids: task_list.task_ids,
      asset_category_id: task_list.asset_category_id}
  end

  def render("task_with_sequence.json", %{task_list: task_tasklists}) do
    %{id: task_tasklists.task.id,
      label: task_tasklists.task.label,
      config: task_tasklists.task.config,
      task_type: task_tasklists.task.task_type,
      master_task_type_id: task_tasklists.task.master_task_type_id,
      estimated_time: task_tasklists.task.estimated_time,
      sequence: task_tasklists.sequence}
  end

  def render("transaction_error.json", %{result: result}) do
    %{errors: %{detail: result}}
  end
end

defmodule Inconn2ServiceWeb.TaskListView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.TaskListView

  def render("index.json", %{task_lists: task_lists}) do
    %{data: render_many(task_lists, TaskListView, "task_list.json")}
  end

  def render("show.json", %{task_list: task_list}) do
    %{data: render_one(task_list, TaskListView, "task_list.json")}
  end

  def render("task_list.json", %{task_list: task_list}) do
    %{id: task_list.id,
      name: task_list.name,
      task_ids: task_list.task_ids,
      asset_category_id: task_list.asset_category_id}
  end
end

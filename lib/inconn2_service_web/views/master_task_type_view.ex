defmodule Inconn2ServiceWeb.MasterTaskTypeView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.MasterTaskTypeView

  def render("index.json", %{master_task_types: master_task_types}) do
    %{data: render_many(master_task_types, MasterTaskTypeView, "master_task_type.json")}
  end

  def render("show.json", %{master_task_type: master_task_type}) do
    %{data: render_one(master_task_type, MasterTaskTypeView, "master_task_type.json")}
  end

  def render("master_task_type.json", %{master_task_type: master_task_type}) do
    %{id: master_task_type.id,
      name: master_task_type.name,
      description: master_task_type.description}
  end
end

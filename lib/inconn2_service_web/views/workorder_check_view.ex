defmodule Inconn2ServiceWeb.WorkorderCheckView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderCheckView

  def render("index.json", %{workorder_checks: workorder_checks}) do
    %{data: render_many(workorder_checks, WorkorderCheckView, "workorder_check.json")}
  end

  def render("show.json", %{workorder_check: workorder_check}) do
    %{data: render_one(workorder_check, WorkorderCheckView, "workorder_check.json")}
  end

  def render("workorder_check_with_check.json", %{workorder_check: workorder_check}) do
    %{id: workorder_check.id,
      check_id: workorder_check.check_id,
      check: render_one(workorder_check.check, WorkorderCheckView, "check.json"),
      type: workorder_check.type,
      approved: workorder_check.approved}
  end

  def render("workorder_check.json", %{workorder_check: workorder_check}) do
    %{id: workorder_check.id,
      check_id: workorder_check.check_id,
      type: workorder_check.type,
      approved: workorder_check.approved}
  end
end

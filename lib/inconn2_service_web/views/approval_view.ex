defmodule Inconn2ServiceWeb.ApprovalView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ApprovalView

  def render("index.json", %{approvals: approvals}) do
    %{data: render_many(approvals, ApprovalView, "approval.json")}
  end

  def render("show.json", %{approval: approval}) do
    %{data: render_one(approval, ApprovalView, "approval.json")}
  end

  def render("approval.json", %{approval: approval}) do
    %{id: approval.id,
      user_id: approval.user_id,
      approved: approval.approved,
      remarks: approval.remarks}
  end
end

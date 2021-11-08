defmodule Inconn2ServiceWeb.WorkRequestView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkRequestView

  def render("index.json", %{work_requests: work_requests}) do
    %{data: render_many(work_requests, WorkRequestView, "work_request.json")}
  end

  def render("show.json", %{work_request: work_request}) do
    %{data: render_one(work_request, WorkRequestView, "work_request.json")}
  end

  def render("work_request.json", %{work_request: work_request}) do
    %{id: work_request.id,
      site_id: work_request.site_id,
      workrequest_category_id: work_request.workrequest_category_id,
      asset_ids: work_request.asset_ids,
      description: work_request.description,
      priority: work_request.priority,
      request_type: work_request.request_type,
      date_of_requirement: work_request.date_of_requirement,
      time_of_requirement: work_request.time_of_requirement,
      requested_user_id: work_request.requested_user_id,
      assigned_user_id: work_request.assigned_user_id,
      attachment_type: work_request.attachment_type,
      status: work_request.status,
      is_approvals_required: work_request.is_approvals_required,
      approvals_required: work_request.approvals_required,
      approved_user_ids: work_request.approved_user_ids,
      rejected_user_ids: work_request.rejected_user_ids}
  end
end

defmodule Inconn2ServiceWeb.WorkRequestView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkRequestView, UserView, WorkrequestSubcategoryView}

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
      workrequest_subcategory: render_one(work_request.workrequest_subcategory, WorkrequestSubcategoryView, "workrequest_subcategory.json"),
      workrequest_subcategory_id: work_request.workrequest_subcategory_id,
      location_id: work_request.location_id,
      asset_id: work_request.asset_id,
      asset_type: work_request.asset_type,
      description: work_request.description,
      priority: work_request.priority,
      request_type: work_request.request_type,
      time_of_requirement: work_request.time_of_requirement,
      requested_user: render_one(work_request.requested_user, UserView, "user.json"),
      assigned_user: render_one(work_request.assigned_user, UserView, "user.json"),
      attachment_type: work_request.attachment_type,
      status: work_request.status,
      is_approvals_required: work_request.is_approvals_required,
      approvals_required: work_request.approvals_required,
      work_order_id: work_request.work_order_id}
  end
end

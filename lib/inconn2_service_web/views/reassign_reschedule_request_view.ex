defmodule Inconn2ServiceWeb.ReassignRescheduleRequestView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ReassignRescheduleRequestView

  def render("index.json", %{reassign_reschedule_requests: reassign_reschedule_requests}) do
    %{data: render_many(reassign_reschedule_requests, ReassignRescheduleRequestView, "reassign_reschedule_request.json")}
  end

  def render("show.json", %{reassign_reschedule_request: reassign_reschedule_request}) do
    %{data: render_one(reassign_reschedule_request, ReassignRescheduleRequestView, "reassign_reschedule_request.json")}
  end

  def render("show_without_preload.json", %{reassign_reschedule_request: reassign_reschedule_request}) do
    %{data: render_one(reassign_reschedule_request, ReassignRescheduleRequestView, "reassign_reschedule_request_without_preload.json")}
  end

  def render("reassign_reschedule_request_without_preload.json", %{reassign_reschedule_request: reassign_reschedule_request}) do
    %{id: reassign_reschedule_request.id,
      requester_user_id: reassign_reschedule_request.requester_user_id,
      reassign_to_user_id: reassign_reschedule_request.reassign_to_user_id,
      reports_to_user_id: reassign_reschedule_request.reports_to_user_id,
      reschedule_date: reassign_reschedule_request.reschedule_date,
      reschedule_time: reassign_reschedule_request.reschedule_time,
      requested_datetime: reassign_reschedule_request.requested_datetime,
      request_for: reassign_reschedule_request.request_for,
      work_order_id: reassign_reschedule_request.work_order_id,
      status: reassign_reschedule_request.status}
  end

  def render("reassign_reschedule_request.json", %{reassign_reschedule_request: reassign_reschedule_request}) do
    %{id: reassign_reschedule_request.id,
      requester_user_id: reassign_reschedule_request.requester_user_id,
      reassign_to_user_id: reassign_reschedule_request.reassign_to_user_id,
      reports_to_user_id: reassign_reschedule_request.reports_to_user_id,
      reschedule_date: reassign_reschedule_request.reschedule_date,
      reschedule_time: reassign_reschedule_request.reschedule_time,
      requested_datetime: reassign_reschedule_request.requested_datetime,
      request_for: reassign_reschedule_request.request_for,
      work_order_id: reassign_reschedule_request.work_order_id,
      asset_name: reassign_reschedule_request.asset_name,
      frequency: reassign_reschedule_request.frequency,
      type: reassign_reschedule_request.type,
      status: reassign_reschedule_request.status}
  end
end

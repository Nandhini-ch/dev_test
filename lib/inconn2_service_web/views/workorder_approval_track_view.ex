defmodule Inconn2ServiceWeb.WorkorderApprovalTrackView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderApprovalTrackView

  def render("index.json", %{workorder_approval_tracks: workorder_approval_tracks}) do
    %{data: render_many(workorder_approval_tracks, WorkorderApprovalTrackView, "workorder_approval_track.json")}
  end

  def render("show.json", %{workorder_approval_track: workorder_approval_track}) do
    %{data: render_one(workorder_approval_track, WorkorderApprovalTrackView, "workorder_approval_track.json")}
  end

  def render("workorder_approval_track.json", %{workorder_approval_track: workorder_approval_track}) do
    %{id: workorder_approval_track.id,
      type: workorder_approval_track.type,
      approved: workorder_approval_track.approved,
      remarks: workorder_approval_track.remarks,
      discrepancy_workorder_check_ids: workorder_approval_track.discrepancy_workorder_check_ids}
  end
end

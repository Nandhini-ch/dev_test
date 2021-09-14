defmodule Inconn2ServiceWeb.WorkorderStatusTrackView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderStatusTrackView

  def render("index.json", %{workorder_status_tracks: workorder_status_tracks}) do
    %{data: render_many(workorder_status_tracks, WorkorderStatusTrackView, "workorder_status_track.json")}
  end

  def render("show.json", %{workorder_status_track: workorder_status_track}) do
    %{data: render_one(workorder_status_track, WorkorderStatusTrackView, "workorder_status_track.json")}
  end

  def render("workorder_status_track.json", %{workorder_status_track: workorder_status_track}) do
    %{id: workorder_status_track.id,
      work_order_id: workorder_status_track.work_order_id,
      status: workorder_status_track.status,
      user_id: workorder_status_track.user_id,
      date_time: workorder_status_track.inserted_at}
  end
end

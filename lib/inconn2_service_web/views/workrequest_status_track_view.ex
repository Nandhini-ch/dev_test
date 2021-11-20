defmodule Inconn2ServiceWeb.WorkrequestStatusTrackView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkrequestStatusTrackView

  def render("index.json", %{workrequest_status_track: workrequest_status_track}) do
    %{data: render_many(workrequest_status_track, WorkrequestStatusTrackView, "workrequest_status_track.json")}
  end

  def render("show.json", %{workrequest_status_track: workrequest_status_track}) do
    %{data: render_one(workrequest_status_track, WorkrequestStatusTrackView, "workrequest_status_track.json")}
  end

  def render("workrequest_status_track.json", %{workrequest_status_track: workrequest_status_track}) do
    %{id: workrequest_status_track.id,
      status: workrequest_status_track.status,
      user_id: workrequest_status_track.user_id,
      status_update_date: workrequest_status_track.status_update_date,
      status_update_time: workrequest_status_track.status_update_time}
  end
end

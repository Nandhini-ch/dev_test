defmodule Inconn2ServiceWeb.AssetStatusTrackView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AssetStatusTrackView

  def render("index.json", %{asset_status_tracks: asset_status_tracks}) do
    %{data: render_many(asset_status_tracks, AssetStatusTrackView, "asset_status_track.json")}
  end

  def render("show.json", %{asset_status_track: asset_status_track}) do
    %{data: render_one(asset_status_track, AssetStatusTrackView, "asset_status_track.json")}
  end

  def render("asset_status_track.json", %{asset_status_track: asset_status_track}) do
    %{id: asset_status_track.id,
      asset_id: asset_status_track.asset_id,
      asset_type: asset_status_track.asset_type,
      status_changed: asset_status_track.status_changed,
      user_id: asset_status_track.user_id,
      changed_date_time: asset_status_track.changed_date_time}
  end
end

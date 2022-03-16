defmodule Inconn2ServiceWeb.AssetStatusTrackController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.AssetStatusTrack

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    asset_status_tracks = AssetConfig.list_asset_status_tracks(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", asset_status_tracks: asset_status_tracks)
  end

  def create(conn, %{"asset_status_track" => asset_status_track_params}) do
    with {:ok, %AssetStatusTrack{} = asset_status_track} <- AssetConfig.create_asset_status_track(asset_status_track_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.asset_status_track_path(conn, :show, asset_status_track))
      |> render("show.json", asset_status_track: asset_status_track)
    end
  end

  def show(conn, %{"id" => id}) do
    asset_status_track = AssetConfig.get_asset_status_track!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", asset_status_track: asset_status_track)
  end

  def update(conn, %{"id" => id, "asset_status_track" => asset_status_track_params}) do
    asset_status_track = AssetConfig.get_asset_status_track!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AssetStatusTrack{} = asset_status_track} <- AssetConfig.update_asset_status_track(asset_status_track, asset_status_track_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", asset_status_track: asset_status_track)
    end
  end

  def delete(conn, %{"id" => id}) do
    asset_status_track = AssetConfig.get_asset_status_track!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AssetStatusTrack{}} <- AssetConfig.delete_asset_status_track(asset_status_track, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

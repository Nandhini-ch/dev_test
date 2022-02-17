defmodule Inconn2ServiceWeb.WorkorderApprovalTrackController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderApprovalTrack

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_approval_tracks = Workorder.list_workorder_approval_tracks(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_approval_tracks: workorder_approval_tracks)
  end

  def create(conn, %{"workorder_approval_track" => workorder_approval_track_params}) do
    with {:ok, %WorkorderApprovalTrack{} = workorder_approval_track} <- Workorder.create_workorder_approval_track(workorder_approval_track_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workorder_approval_track_path(conn, :show, workorder_approval_track))
      |> render("show.json", workorder_approval_track: workorder_approval_track)
    end
  end

  def show(conn, %{"id" => id}) do
    workorder_approval_track = Workorder.get_workorder_approval_track!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_approval_track: workorder_approval_track)
  end

  def update(conn, %{"id" => id, "workorder_approval_track" => workorder_approval_track_params}) do
    workorder_approval_track = Workorder.get_workorder_approval_track!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderApprovalTrack{} = workorder_approval_track} <- Workorder.update_workorder_approval_track(workorder_approval_track, workorder_approval_track_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", workorder_approval_track: workorder_approval_track)
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_approval_track = Workorder.get_workorder_approval_track!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderApprovalTrack{}} <- Workorder.delete_workorder_approval_track(workorder_approval_track, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

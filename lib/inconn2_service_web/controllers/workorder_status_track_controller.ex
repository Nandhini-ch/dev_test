defmodule Inconn2ServiceWeb.WorkorderStatusTrackController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder

  action_fallback Inconn2ServiceWeb.FallbackController


  def index(conn, %{"work_order_id" => work_order_id}) do
    workorder_status_tracks = Workorder.list_status_track_by_work_order_id(work_order_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_status_tracks: workorder_status_tracks)
  end

end

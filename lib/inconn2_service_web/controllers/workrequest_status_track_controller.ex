defmodule Inconn2ServiceWeb.WorkrequestStatusTrackController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestStatusTrack

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
  workrequest_status_track = Ticket.list_workrequest_status_track(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workrequest_status_track: workrequest_status_track)
  end

  def create(conn, %{"workrequest_status_track" => workrequest_status_track_params}) do
    with {:ok, %WorkrequestStatusTrack{} = workrequest_status_track} <- Ticket.create_workrequest_status_track(workrequest_status_track_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workrequest_status_track_path(conn, :show, workrequest_status_track))
      |> render("show.json", workrequest_status_track: workrequest_status_track)
    end
  end

  def show(conn, %{"id" => id}) do
    workrequest_status_track = Ticket.get_workrequest_status_track!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workrequest_status_track: workrequest_status_track)
  end

  def update(conn, %{"id" => id, "workrequest_status_track" => workrequest_status_track_params}) do
    workrequest_status_track = Ticket.get_workrequest_status_track!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkrequestStatusTrack{} = workrequest_status_track} <- Ticket.update_workrequest_status_track(workrequest_status_track, workrequest_status_track_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workrequest_status_track: workrequest_status_track)
    end
  end

  def delete(conn, %{"id" => id}) do
    workrequest_status_track = Ticket.get_workrequest_status_track!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkrequestStatusTrack{}} <- Ticket.delete_workrequest_status_track(workrequest_status_track, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

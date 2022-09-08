defmodule Inconn2ServiceWeb.MasterRosterController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignments
  alias Inconn2Service.Assignments.MasterRoster

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    master_rosters = Assignments.list_master_rosters()
    render(conn, "index.json", master_rosters: master_rosters)
  end

  def create(conn, %{"master_roster" => master_roster_params}) do
    with {:ok, %MasterRoster{} = master_roster} <- Assignments.create_master_roster(master_roster_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.master_roster_path(conn, :show, master_roster))
      |> render("show.json", master_roster: master_roster)
    end
  end

  def show(conn, %{"id" => id}) do
    master_roster = Assignments.get_master_roster!(id)
    render(conn, "show.json", master_roster: master_roster)
  end

  def update(conn, %{"id" => id, "master_roster" => master_roster_params}) do
    master_roster = Assignments.get_master_roster!(id)

    with {:ok, %MasterRoster{} = master_roster} <- Assignments.update_master_roster(master_roster, master_roster_params) do
      render(conn, "show.json", master_roster: master_roster)
    end
  end

  def delete(conn, %{"id" => id}) do
    master_roster = Assignments.get_master_roster!(id)

    with {:ok, %MasterRoster{}} <- Assignments.delete_master_roster(master_roster) do
      send_resp(conn, :no_content, "")
    end
  end
end

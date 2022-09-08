defmodule Inconn2ServiceWeb.RosterController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignments
  alias Inconn2Service.Assignments.Roster

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, params) do
    master_roster = Assignments.get_master_roster(params, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", master_roster: master_roster)
  end

  def create_or_update(conn, %{"roster" => roster_params}) do
    master_roster = Assignments.create_or_update_master_rosters(roster_params, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", master_roster: master_roster)
  end
  # def index(conn, _params) do
  #   rosters = Assignments.list_rosters()
  #   render(conn, "index.json", rosters: rosters)
  # end

  # def create(conn, %{"roster" => roster_params}) do
  #   with {:ok, %Roster{} = roster} <- Assignments.create_roster(roster_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.roster_path(conn, :show, roster))
  #     |> render("show.json", roster: roster)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   roster = Assignments.get_roster!(id)
  #   render(conn, "show.json", roster: roster)
  # end

  # def update(conn, %{"id" => id, "roster" => roster_params}) do
  #   roster = Assignments.get_roster!(id)

  #   with {:ok, %Roster{} = roster} <- Assignments.update_roster(roster, roster_params) do
  #     render(conn, "show.json", roster: roster)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   roster = Assignments.get_roster!(id)

  #   with {:ok, %Roster{}} <- Assignments.delete_roster(roster) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end

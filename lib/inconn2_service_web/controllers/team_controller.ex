defmodule Inconn2ServiceWeb.TeamController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Team

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    teams = Staff.list_teams(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", teams: teams)
  end

  def index_for_user(conn, _params) do
    teams = Staff.list_teams_for_user(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", teams: teams)
  end

  def create(conn, %{"team" => team_params}) do
    with {:ok, %Team{} = team} <- Staff.create_team(team_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.team_path(conn, :show, team))
      |> render("show.json", team: team)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Staff.get_team!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", team: team)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Staff.get_team!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Team{} = team} <- Staff.update_team(team, team_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", team: team)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Staff.get_team!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Team{}} <- Staff.delete_team(team, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

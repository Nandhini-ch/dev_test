defmodule Inconn2ServiceWeb.TeamMemberController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    team_members = Staff.list_team_members(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", team_members: team_members)
  end

  def create(conn, %{"team_id" => team_id, "employee_ids" => employee_ids}) do
    with team_members <- Staff.create_team_members(team_id, employee_ids, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> render("index.json", team_members: team_members)
    end
  end

  def show(conn, %{"id" => id}) do
    team_member = Staff.get_team_member!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", team_member: team_member)
  end

  def delete(conn, %{"team_id" => team_id, "employee_ids" => employee_ids}) do
    with _ <- Staff.delete_team_members(team_id, employee_ids, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end

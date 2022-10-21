defmodule Inconn2ServiceWeb.TeamMemberView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{TeamMemberView, EmployeeView}

  def render("index.json", %{team_members: team_members}) do
    %{data: render_many(team_members, TeamMemberView, "team_member.json")}
  end

  def render("show.json", %{team_member: team_member}) do
    %{data: render_one(team_member, TeamMemberView, "team_member.json")}
  end

  def render("team_member.json", %{team_member: team_member}) do
    %{id: team_member.id,
      team_id: team_member.team_id,
      employee_id: team_member.employee_id,
      employee: render_one(team_member.employee, EmployeeView, "employee_without_org_unit.json")}
  end
end

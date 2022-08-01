defmodule Inconn2ServiceWeb.EmployeeRosterView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{EmployeeRosterView, EmployeeView, SiteView, ShiftView}

  def render("index.json", %{employee_rosters: employee_rosters}) do
    %{data: render_many(employee_rosters, EmployeeRosterView, "employee_roster.json")}
  end

  def render("show.json", %{employee_roster: employee_roster}) do
    %{data: render_one(employee_roster, EmployeeRosterView, "employee_roster.json")}
  end

  def render("employee_roster.json", %{employee_roster: employee_roster}) do
    %{id: employee_roster.id,
      employee: render_one(employee_roster.employee, EmployeeView, "employee_with_org_unit_only.json"),
      site: render_one(employee_roster.site, SiteView, "site.json"),
      shift: render_one(employee_roster.shift, ShiftView, "shift.json"),
      start_date: employee_roster.start_date,
      end_date: employee_roster.end_date}
  end

  def render("site_index.json", %{sites: sites}) do
    %{data: render_many(sites, SiteView, "site.json")}
  end

  def render("employee_index.json", %{employees: employees}) do
    %{data: render_many(employees, EmployeeView, "employee_without_org_unit.json")}
  end

end

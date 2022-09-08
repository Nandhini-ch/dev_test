defmodule Inconn2ServiceWeb.RosterView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.RosterView

  def render("show.json", %{master_roster: master_roster}) do
    %{data: render_one(master_roster, RosterView, "master_roster.json")}
  end

  def render("master_roster.json", %{roster: master_roster}) do
    %{
      id: master_roster.id,
      site_id: master_roster.site_id,
      site_name: master_roster.site.name,
      designation_id: master_roster.designation_id,
      designation_name: master_roster.designation.name,
      assignment: render_many(master_roster.rosters, RosterView, "roster.json")
    }
  end

  def render("roster.json", %{roster: roster}) do
    %{id: roster.id,
      shift_id: roster.shift_id,
      shift_name: roster.shift.name,
      shift_code: roster.shift.code,
      employee_id: roster.employee_id,
      employee_first_name: roster.employee.first_name,
      employee_last_name: roster.employee.last_name,
      date: roster.date}
  end
end

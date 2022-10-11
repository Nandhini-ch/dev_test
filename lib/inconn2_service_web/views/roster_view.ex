defmodule Inconn2ServiceWeb.RosterView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{RosterView, SiteView}

  def render("show.json", %{master_roster: master_roster}) do
    %{data: render_one(master_roster, RosterView, "master_roster.json")}
  end

  def render("my_rosters.json", %{rosters: rosters}) do
    %{data: render_many(rosters, RosterView, "my_roster.json")}
  end

  def render("my_roster.json", %{roster: roster}) do
    %{
      name: roster.shift_code,
      start: roster.date
    }
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
      shift_name: roster.shift_name,
      shift_code: roster.shift_code,
      employee_id: roster.employee_id,
      employee_first_name: roster.employee_first_name,
      employee_last_name: roster.employee_last_name,
      date: roster.date}
  end

  def render("site_index.json", %{sites: sites}) do
    %{data: render_many(sites, SiteView, "site.json")}
  end
end

defmodule Inconn2ServiceWeb.MasterRosterView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.MasterRosterView

  def render("index.json", %{master_rosters: master_rosters}) do
    %{data: render_many(master_rosters, MasterRosterView, "master_roster.json")}
  end

  def render("show.json", %{master_roster: master_roster}) do
    %{data: render_one(master_roster, MasterRosterView, "master_roster.json")}
  end

  def render("master_roster.json", %{master_roster: master_roster}) do
    %{id: master_roster.id,
      active: master_roster.active}
  end
end

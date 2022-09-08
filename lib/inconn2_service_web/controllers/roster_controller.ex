defmodule Inconn2ServiceWeb.RosterController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignments

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, params) do
    master_roster = Assignments.get_master_roster(params, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", master_roster: master_roster)
  end

  def create_or_update(conn, %{"roster" => roster_params}) do
    master_roster = Assignments.create_or_update_master_rosters(roster_params, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", master_roster: master_roster)
  end

end

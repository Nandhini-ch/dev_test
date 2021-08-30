defmodule Inconn2ServiceWeb.OrgUnitView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.OrgUnitView

  def render("index.json", %{org_units: org_units}) do
    %{data: render_many(org_units, OrgUnitView, "org_unit.json")}
  end

  def render("show.json", %{org_unit: org_unit}) do
    %{data: render_one(org_unit, OrgUnitView, "org_unit.json")}
  end

  def render("org_unit.json", %{org_unit: org_unit}) do
    %{id: org_unit.id,
      name: org_unit.name}
  end
end

defmodule Inconn2ServiceWeb.DesignationView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.DesignationView

  def render("index.json", %{designations: designations}) do
    %{data: render_many(designations, DesignationView, "designation.json")}
  end

  def render("show.json", %{designation: designation}) do
    %{data: render_one(designation, DesignationView, "designation.json")}
  end

  def render("designation.json", %{designation: designation}) do
    %{id: designation.id,
      name: designation.name,
      description: designation.description}
  end
end

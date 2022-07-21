defmodule Inconn2ServiceWeb.CheckTypeView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.CheckTypeView

  def render("index.json", %{check_types: check_types}) do
    %{data: render_many(check_types, CheckTypeView, "check_type.json")}
  end

  def render("show.json", %{check_type: check_type}) do
    %{data: render_one(check_type, CheckTypeView, "check_type.json")}
  end

  def render("check_type.json", %{check_type: check_type}) do
    %{id: check_type.id,
      name: check_type.name,
      description: check_type.description}
  end
end

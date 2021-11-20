defmodule Inconn2ServiceWeb.ModuleView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ModuleView

  def render("index.json", %{modules: modules}) do
    %{data: render_many(modules, ModuleView, "module.json")}
  end

  def render("show.json", %{module: module}) do
    %{data: render_one(module, ModuleView, "module.json")}
  end

  def render("module.json", %{module: module}) do
    %{id: module.id,
      name: module.name,
      description: module.description,
      feature_ids: module.feature_ids}
  end
end

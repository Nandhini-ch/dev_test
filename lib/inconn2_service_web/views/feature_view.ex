defmodule Inconn2ServiceWeb.FeatureView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.FeatureView

  def render("index.json", %{features: features}) do
    %{data: render_many(features, FeatureView, "feature.json")}
  end

  def render("show.json", %{feature: feature}) do
    %{data: render_one(feature, FeatureView, "feature.json")}
  end

  def render("feature.json", %{feature: feature}) do
    %{id: feature.id,
      name: feature.name,
      code: feature.code,
      module_id: feature.module_id}
  end
end

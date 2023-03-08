defmodule Inconn2ServiceWeb.IotService.AssetView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.IotService.AssetView

  def render("index.json", %{assets: assets}) do
    %{data: render_many(assets, AssetView, "asset.json")}
  end

  def render("show.json", %{asset: asset}) do
    %{data: render_one(asset, AssetView, "asset.json")}
  end

  def render("asset.json", %{asset: asset}) do
    %{id: asset.id,
      asset_type: asset.asset_type,
      asset_name: asset.name}
  end
end

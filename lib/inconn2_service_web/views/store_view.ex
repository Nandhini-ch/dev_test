defmodule Inconn2ServiceWeb.StoreView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.StoreView

  def render("index.json", %{stores: stores}) do
    %{data: render_many(stores, StoreView, "store.json")}
  end

  def render("show.json", %{store: store}) do
    %{data: render_one(store, StoreView, "store.json")}
  end

  def render("store.json", %{store: store}) do
    %{id: store.id,
      name: store.name,
      description: store.description,
      location_id: store.location_id,
      aisle_count: store.aisle_count,
      aisle_notation: store.aisle_notation,
      row_count: store.row_count,
      row_notation: store.row_notation,
      bin_count: store.bin_count,
      bin_notation: store.bin_notation}
  end
end

defmodule Inconn2ServiceWeb.StoreView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{LocationView, SiteView, StoreView, UserView}

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
      person_or_location_based: store.person_or_location_based,
      user_id: store.user_id,
      user: (if is_nil(store.user), do: nil, else: render_one(store.user, UserView, "user.json")),
      site_id: store.site_id,
      site: (if is_nil(store.site), do: nil, else: render_one(store.site, SiteView, "site.json")),
      is_layout_configuration_required: store.is_layout_configuration_required,
      location_id: store.location_id,
      location: (if is_nil(store.location), do: nil, else: render_one(store.location, LocationView, "location.json")),
      aisle_count: store.aisle_count,
      aisle_notation: store.aisle_notation,
      row_count: store.row_count,
      row_notation: store.row_notation,
      bin_count: store.bin_count,
      bin_notation: store.bin_notation}
  end
end

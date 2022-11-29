defmodule Inconn2ServiceWeb.StoreView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{LocationView, SiteView, StoreView, UserView}

  def render("index.json", %{stores: stores}) do
    %{data: render_many(stores, StoreView, "store.json")}
  end

  def render("show.json", %{store: store}) do
    %{data: render_one(store, StoreView, "store.json")}
  end

  def render("store_without_content.json", %{store: store}) do
    %{id: store.id,
      name: store.name,
      description: store.description,
      person_or_location_based: store.person_or_location_based,
      user_id: store.user_id,
      site_id: store.site_id,
      is_layout_configuration_required: store.is_layout_configuration_required,
      location_id: store.location_id,
      aisle_count: store.aisle_count,
      aisle_notation: store.aisle_notation,
      row_count: store.row_count,
      row_notation: store.row_notation,
      bin_count: store.bin_count,
      bin_notation: store.bin_notation,
      storekeeper_user_id: store.storekeeper_user_id,
      store_image_name: store.store_image_name,
      store_image_type: store.store_image_type}
  end

  def render("store.json", %{store: store}) do
    %{id: store.id,
      name: store.name,
      description: store.description,
      person_or_location_based: store.person_or_location_based,
      user_id: store.user_id,
      user: (if is_nil(store.user), do: nil, else: render_one(store.user, UserView, "user_without_org_unit.json")),
      storekeeper_user_id: store.storekeeper_user_id,
      storekeeper_user: (if is_nil(store.storekeeper_user), do: nil, else: render_one(store.storekeeper_user, UserView, "user_without_org_unit.json")),
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
      bin_notation: store.bin_notation,
      store_image_name: store.store_image_name,
      store_image_type: store.store_image_type}
  end
end

defmodule Inconn2Service.AssetConfig do
  @moduledoc """
  The AssetConfig context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Multi
  alias Inconn2Service.Repo

  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.AssetConfig.AssetStatusTrack
  alias Inconn2Service.AssetConfig.{Equipment, Location}
  alias Inconn2Service.Util.HierarchyManager
  # alias Inconn2Service.Account.Licensee

  @doc """
  Returns the list of sites.

  ## Examples

      iex> list_sites()
      [%Site{}, ...]

  """
  def list_sites(prefix) do
    Repo.all(Site, prefix: prefix)
    |> sort_sites()
  end

  defp sort_sites(sites) do
    Enum.sort_by(sites, &(&1.name))
  end

  def list_sites(query_params, prefix) do
   Site
   |> Repo.add_active_filter(query_params)
   |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single site.

  Raises `Ecto.NoResultsError` if the Site does not exist.

  ## Examples

      iex> get_site!(123)
      %Site{}

      iex> get_site!(456)
      ** (Ecto.NoResultsError)

  """
  def get_site!(id, prefix), do: Repo.get!(Site, id, prefix: prefix)

  @doc """
  Creates a site.

  ## Examples

      iex> create_site(%{field: value})
      {:ok, %Site{}}

      iex> create_site(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_site(attrs \\ %{}, prefix) do
    # When create site is called with a party id then we
    # need to check if the licensee is a Assset Owner with Licensee Y
    IO.inspect(attrs)
    party_id = Map.get(attrs, "party_id", nil)
    IO.inspect(party_id)

    if party_id == nil do
      site =
        %Site{}
        |> Site.changeset(attrs)
        |> add_error(:party_id, "Cannot create site, without a Party")

      IO.inspect(site)
    else
      #  result = IO.inspect(get_party_AO(party_id, prefix))
      #  IO.inspect(result) checking for AO, SELF
      result = IO.inspect(get_party_AO(party_id, prefix))
      IO.puts("im here inside create site&&&&&&&&&&&&")
      IO.inspect(result)

      case result do
        nil ->
          site =
            %Site{}
            |> Site.changeset(attrs)
            |> add_error(
              :party_id,
              "Cannot create site, There is no Licensee / Party - Asset owner for this site"
            )

          IO.inspect(site)

        {:error, change_set} ->
          IO.inspect(change_set)
          change_set

        _change_set ->
          site =
            %Site{}
            |> Site.changeset(attrs)
            |> Repo.insert(prefix: prefix)

          IO.inspect(site)
      end
    end
  end

  @doc """
  Updates a site.

  ## Examples

      iex> update_site(site, %{field: new_value})
      {:ok, %Site{}}

      iex> update_site(site, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_site(%Site{} = site, attrs, prefix) do
    site
    |> Site.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def update_site_active_status(%Site{} = site, attrs, prefix) do
    site
    |> Site.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end


  @doc """
  Deletes a site.

  ## Examples

      iex> delete_site(site)
      {:ok, %Site{}}

      iex> delete_site(site)
      {:error, %Ecto.Changeset{}}

  """
  def delete_site(%Site{} = site, prefix) do
    Repo.delete(site, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site changes.

  ## Examples

      iex> change_site(site)
      %Ecto.Changeset{data: %Site{}}

  """
  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  def get_assets_by_asset_category_id(asset_category_id, prefix) do
    asset_category = get_asset_category!(asset_category_id, prefix)
    case asset_category.asset_type do
      "L" ->
         Location |> where([asset_category_id: ^asset_category_id]) |> Repo.all(prefix: prefix)

      "E" ->
        Equipment |> where([asset_category_id: ^asset_category_id]) |> Repo.all(prefix: prefix)
    end
  end

  alias Inconn2Service.AssetConfig.AssetCategory

  @doc """
  Returns the list of asset_categories.

  ## Examples

      iex> list_asset_categories()
      [%AssetCategory{}, ...]

  """
  def list_asset_categories(prefix) do
    AssetCategory
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories(query_params, prefix) do
    AssetCategory
    |> Repo.add_active_filter(query_params)
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories_by_type(type, prefix) do
    AssetCategory
    |> where(asset_type: ^type)
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories_by_type(type, query_params, prefix) do
    AssetCategory
    |> Repo.add_active_filter(query_params)
    |> where(asset_type: ^type)
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories_tree(prefix) do
    list_asset_categories(%{"active" => "true"}, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_asset_categories_leaves(prefix) do
    ids =
      list_asset_categories(%{"active" => "true"}, prefix)
      |> HierarchyManager.leaf_nodes()
      |> MapSet.to_list()

    from(a in AssetCategory, where: a.id in ^ids) |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single asset_category.

  Raises `Ecto.NoResultsError` if the AssetCategory does not exist.

  ## Examples

      iex> get_asset_category!(123)
      %AssetCategory{}

      iex> get_asset_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_asset_category!(id, prefix), do: Repo.get!(AssetCategory, id, prefix: prefix)
  def get_asset_category(id, prefix), do: Repo.get(AssetCategory, id, prefix: prefix)

  def get_root_asset_categories(prefix) do
    root_path = []

    query =
      from(a in AssetCategory,
        where: fragment("(?) = ?", field(a, :path), ^root_path)
      )

    Repo.all(query, prefix: prefix)
  end

  def get_parent_of_asset_category(asset_category_id, prefix) do
    ac = get_asset_category!(asset_category_id, prefix)
    HierarchyManager.parent(ac) |> Repo.one(prefix: prefix)
  end

  alias Inconn2Service.AssetConfig.Location
  alias Inconn2Service.AssetConfig.Equipment

  def get_assets(id, prefix) do
    asset_category = get_asset_category!(id, prefix)
    asset_type = asset_category.asset_type
    subtree = HierarchyManager.subtree(asset_category) |> Repo.all(prefix: prefix)
    ids = Enum.map(subtree, fn x -> Map.fetch!(x, :id) end)

    case asset_type do
      "L" -> from(l in Location, where: l.asset_category_id in ^ids) |> Repo.all(prefix: prefix)
      "E" -> from(e in Equipment, where: e.asset_category_id in ^ids) |> Repo.all(prefix: prefix)
    end
  end

  @doc """
  Creates a asset_category.

  ## Examples

      iex> create_asset_category(%{field: value})
      {:ok, %AssetCategory{}}

      iex> create_asset_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_asset_category(attrs \\ %{}, prefix) do
    parent_id = Map.get(attrs, "parent_id", nil)

    if parent_id != nil do
      attrs = add_or_change_asset_type_new_parent(attrs, parent_id, prefix)
      create_asset_category_with_asset_type(attrs, parent_id, prefix)
    else
      create_asset_category_with_asset_type(attrs, parent_id, prefix)
    end
  end

  defp create_asset_category_with_asset_type(attrs, parent_id, prefix) do
    ac_cs =
      %AssetCategory{}
      |> AssetCategory.changeset(attrs)

    create_asset_category_in_tree(parent_id, ac_cs, prefix)
  end

  defp create_asset_category_in_tree(nil, ac_cs, prefix) do
    Repo.insert(ac_cs, prefix: prefix)
  end

  defp create_asset_category_in_tree(parent_id, ac_cs, prefix) do
    case Repo.get(AssetCategory, parent_id, prefix: prefix) do
      nil ->
        add_error(ac_cs, :parent_id, "Parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        ac_cs
        |> HierarchyManager.make_child_of(parent)
        |> Repo.insert(prefix: prefix)
    end
  end

  @doc """
  Updates a asset_category.

  ## Examples

      iex> update_asset_category(asset_category, %{field: new_value})
      {:ok, %AssetCategory{}}

      iex> update_asset_category(asset_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_asset_category(%AssetCategory{} = asset_category, attrs, prefix) do
    existing_parent_id = HierarchyManager.parent_id(asset_category)

    cond do
      Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
        new_parent_id = attrs["parent_id"]
        attrs = add_or_change_asset_type_new_parent(attrs, new_parent_id, prefix)
        ac_cs = update_asset_category_default_changeset_pipe(asset_category, attrs, prefix)
        update_asset_category_in_tree(new_parent_id, ac_cs, asset_category, prefix)

      true ->
        attrs = add_or_change_asset_type(attrs, asset_category, prefix)

        update_asset_category_default_changeset_pipe(asset_category, attrs, prefix)
        |> Repo.update(prefix: prefix)
    end
  end

  def update_active_status_for_asset_category(%AssetCategory{} = asset_category, asset_params, prefix) do
    case asset_params do
      %{"active" => false} ->
        children = HierarchyManager.children(asset_category)
        IO.inspect(children)
        Repo.update_all(children, [set: [active: false]], prefix: prefix)
        asset_category
        |> AssetCategory.changeset(asset_params)
        |> Repo.update(prefix: prefix)

      %{"active" => true} ->
        parent_id = HierarchyManager.parent_id(asset_category)
        asset_category
        |> AssetCategory.changeset(asset_params)
        |> validate_parent_for_true_condition(AssetCategory, prefix, parent_id)
        |> Repo.update(prefix: prefix)
        |> update_children(prefix)
    end
  end

  defp add_or_change_asset_type_new_parent(attrs, new_parent_id, prefix) do
    parent = Repo.get(AssetCategory, new_parent_id, prefix: prefix)

    if parent != nil do
      Map.put(attrs, "asset_type", parent.asset_type)
    else
      attrs
    end
  end

  defp add_or_change_asset_type(attrs, asset_category, prefix) do
    parent = HierarchyManager.parent(asset_category) |> Repo.one(prefix: prefix)

    if parent != nil do
      Map.put(attrs, "asset_type", parent.asset_type)
    else
      attrs
    end
  end

  defp update_asset_category_in_tree(nil, ac_cs, asset_category, prefix) do
    descendents = HierarchyManager.descendants(asset_category) |> Repo.all(prefix: prefix)
    # adjust the path (from old path to ne path )for all descendents
    ac_cs = change(ac_cs, %{path: []})
    make_asset_categories_changeset_and_update(ac_cs, asset_category, descendents, [], prefix)
  end

  defp update_asset_category_in_tree(new_parent_id, ac_cs, asset_category, prefix) do
    # Get the new parent and check
    case Repo.get(AssetCategory, new_parent_id, prefix: prefix) do
      nil ->
        add_error(ac_cs, :parent_id, "New parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        # Get the descendents
        descendents = HierarchyManager.descendants(asset_category) |> Repo.all(prefix: prefix)
        new_path = parent.path ++ [parent.id]
        # make this node child of new parent
        head_cs = HierarchyManager.make_child_of(ac_cs, parent)

        make_asset_categories_changeset_and_update(
          head_cs,
          asset_category,
          descendents,
          new_path,
          prefix
        )
    end
  end

  defp make_asset_categories_changeset_and_update(
         head_cs,
         asset_category,
         descendents,
         new_path,
         prefix
       ) do
    # adjust the path (from old path to ne path )for all descendents
    multi =
      [
        {asset_category.id, head_cs}
        | Enum.map(descendents, fn d ->
            {_, rest} = Enum.split_while(d.path, fn e -> e != asset_category.id end)
            {d.id, AssetCategory.changeset(d, %{}) |> change(%{path: new_path ++ rest})}
          end)
      ]
      |> Enum.reduce(Multi.new(), fn {indx, cs}, multi ->
        Multi.update(multi, :"asset_category#{indx}", cs, prefix: prefix)
      end)

    case Repo.transaction(multi, prefix: prefix) do
      {:ok, ac} -> {:ok, Map.get(ac, :"asset_category#{asset_category.id}")}
      _ -> {:error, head_cs}
    end
  end

  defp update_asset_category_default_changeset_pipe(
         %AssetCategory{} = asset_category,
         attrs,
         _prefix
       ) do
    asset_category
    |> AssetCategory.changeset(attrs)
  end

  @doc """
  Deletes a asset_category.

  ## Examples

      iex> delete_asset_category(asset_category)
      {:ok, %AssetCategory{}}

      iex> delete_asset_category(asset_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_asset_category(%AssetCategory{} = asset_category, prefix) do
    # Deletes the asset_category and children forcibly
    # TBD: do not allow delete if this asset_category is linked to some other record(s)
    # Add that validation here....
    subtree = HierarchyManager.subtree(asset_category)
    Repo.delete_all(subtree, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking asset_category changes.

  ## Examples

      iex> change_asset_category(asset_category)
      %Ecto.Changeset{data: %AssetCategory{}}

  """
  def change_asset_category(%AssetCategory{} = asset_category, attrs \\ %{}) do
    AssetCategory.changeset(asset_category, attrs)
  end

  alias Inconn2Service.AssetConfig.Location

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations(site_id, prefix) do
    Location
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
  end

  def search_locations(name_text, site_id, prefix) do
    if String.length(name_text) < 3 do
      []
    else
      search_text = "%" <> name_text <> "%"

      from(l in Location, where: l.site_id == ^site_id and ilike(l.name, ^search_text), order_by: l.name)
      |> Repo.all(prefix: prefix)
    end
  end

  def list_locations(site_id, query_params, prefix) do
    Location
    |> Repo.add_active_filter(query_params)
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
  end

  def list_active_locations(prefix) do
    Location
    |> where(active: true)
    |> Repo.all(prefix: prefix)
  end

  def list_locations_tree(site_id, prefix) do
    list_locations(site_id, %{"active" => "true"}, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_locations_leaves(site_id, prefix) do
    ids =
      list_locations(site_id, %{"active" => "true"}, prefix)
      |> HierarchyManager.leaf_nodes()
      |> MapSet.to_list()

    from(l in Location, where: l.id in ^ids) |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id, prefix), do: Repo.get!(Location, id, prefix: prefix)
  def get_location(id, prefix), do: Repo.get(Location, id, prefix: prefix)

  def get_location_qr_code(id, prefix) do
    location = get_location(id, prefix)
    {EQRCode.encode("L:" <> location.qr_code) |> EQRCode.png, location}
  end

  def get_location_by_qr_code(qr_code, prefix), do: Repo.get_by(Location, [qr_code: qr_code], prefix: prefix)


  def get_root_locations(site_id, prefix) do
    root_path = []

    query =
      from(l in Location,
        where: fragment("(?) = ?", field(l, :path), ^root_path) and l.site_id == ^site_id
      )

    Repo.all(query, prefix: prefix)
  end

  def get_parent_of_location(location_id, prefix) do
    loc = get_location!(location_id, prefix)
    HierarchyManager.parent(loc) |> Repo.one(prefix: prefix)
  end

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}, prefix) do
    parent_id = Map.get(attrs, "parent_id", nil)

    loc_cs =
      %Location{}
      |> Location.changeset(attrs)
      |> check_asset_category_type_loc(prefix)

    result = create_location_in_tree(parent_id, loc_cs, prefix)

    case result do
      {:ok, location} ->
        create_track_for_asset_status(location, "L", prefix)

      _ ->
        result
    end
  end

  defp create_location_in_tree(nil, loc_cs, prefix) do
    Repo.insert(loc_cs, prefix: prefix)
  end

  defp create_location_in_tree(parent_id, loc_cs, prefix) do
    case Repo.get(Location, parent_id, prefix: prefix) do
      nil ->
        add_error(loc_cs, :parent_id, "Parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        loc_cs
        |> HierarchyManager.make_child_of(parent)
        |> Repo.insert(prefix: prefix)
    end
  end

  defp check_asset_category_type_loc(loc_cs, prefix) do
    ac_id = get_change(loc_cs, :asset_category_id, nil)

    if ac_id != nil do
      asset_category = Repo.get(AssetCategory, ac_id, prefix: prefix)
      if asset_category != nil do
        case asset_category.asset_type != "L" do
          true ->
            add_error(loc_cs, :asset_category_id, "Asset category should be location")

          false ->
            loc_cs
        end
      else
        loc_cs
      end
    else
      loc_cs
    end
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs, prefix, user \\ %{}) do
    existing_parent_id = HierarchyManager.parent_id(location)

    result =
      cond do
        Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
          new_parent_id = attrs["parent_id"]

          loc_cs =
            update_location_default_changeset_pipe(location, attrs, prefix)
            |> check_asset_category_type_loc(prefix)

          update_location_in_tree(new_parent_id, loc_cs, location, prefix)

        true ->
          loc_cs =
            update_location_default_changeset_pipe(location, attrs, prefix)
            |> check_asset_category_type_loc(prefix)

          Repo.update(loc_cs, prefix: prefix)
      end

    # create_status_track_for_asset(result, location, attrs, "L", user, prefix)

    case result do
      {:ok, updated_location} ->
        update_status_track_for_asset(updated_location, location.status, "L", user, prefix)

      _ ->
        result
    end

  end

  defp update_status_track_for_asset(asset, previous_status, _asset_type, _user, _prefix) when asset.status == previous_status do
    {:ok, asset}
  end

  defp update_status_track_for_asset(asset, _previous_status, asset_type, user, prefix) do
    update_last_status_record(asset, asset_type, prefix)
    create_track_for_asset_status(asset, asset_type, prefix, user.id)
  end

  defp update_last_status_record(asset, asset_type, prefix) do
    query =
      from(ast in AssetStatusTrack,
          where: ast.asset_id == ^asset.id and
                ast.asset_type == ^asset_type,
                order_by: [desc: ast.changed_date_time], limit: 1)

    last_entry = Repo.one(query, prefix: prefix)

    time_zone = get_site_time_zone_from_asset(asset.site_id, prefix)

    {:ok, current_date_time} = DateTime.now(time_zone)

    attrs = %{
      "hours" => NaiveDateTime.diff(DateTime.to_naive(current_date_time), last_entry.changed_date_time) / 3600
    }

    IO.inspect("&&&&&&&&&&&&&&&&&&&&")
    IO.inspect(attrs)
    IO.inspect(NaiveDateTime.diff(DateTime.to_naive(current_date_time), last_entry.changed_date_time) /3600 )

    update_asset_status_track(last_entry, attrs, prefix)
  end

  def create_status_track_for_asset(result, asset_before_insertion, attrs, asset_type, user, prefix) do
    case result do
      {:ok, asset} ->
        if attrs["status"] != asset_before_insertion.status do
          IO.inspect("Inside If")
          asset_status_update_attrs = %{
            "asset_id" => asset.id,
            "asset_type" => asset_type,
            "status_changed" => asset.status,
            "user_id" => user.id,
            "changed_date_time" => NaiveDateTime.utc_now(),
          }
          IO.inspect(create_asset_status_track(asset_status_update_attrs, prefix))
          {:ok, asset}

        else
          {:ok, asset}
        end
      _ ->
        result
    end
  end


  defp update_location_in_tree(nil, loc_cs, location, prefix) do
    descendents = HierarchyManager.descendants(location) |> Repo.all(prefix: prefix)
    # adjust the path (from old path to ne path )for all descendents
    loc_cs = change(loc_cs, %{path: []})
    make_locations_changeset_and_update(loc_cs, location, descendents, [], prefix)
  end

  defp update_location_in_tree(new_parent_id, loc_cs, location, prefix) do
    # Get the new parent and check
    case Repo.get(Location, new_parent_id, prefix: prefix) do
      nil ->
        add_error(loc_cs, :parent_id, "New parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        # Get the descendents
        descendents = HierarchyManager.descendants(location) |> Repo.all(prefix: prefix)
        new_path = parent.path ++ [parent.id]
        # make this node child of new parent
        head_cs = HierarchyManager.make_child_of(loc_cs, parent)
        make_locations_changeset_and_update(head_cs, location, descendents, new_path, prefix)
    end
  end

  defp make_locations_changeset_and_update(head_cs, location, descendents, new_path, prefix) do
    # adjust the path (from old path to ne path )for all descendents
    multi =
      [
        {location.id, head_cs}
        | Enum.map(descendents, fn d ->
            {_, rest} = Enum.split_while(d.path, fn e -> e != location.id end)
            {d.id, Location.changeset(d, %{}) |> change(%{path: new_path ++ rest})}
          end)
      ]
      |> Enum.reduce(Multi.new(), fn {indx, cs}, multi ->
        Multi.update(multi, :"location#{indx}", cs, prefix: prefix)
      end)

    case Repo.transaction(multi, prefix: prefix) do
      {:ok, loc} -> {:ok, Map.get(loc, :"location#{location.id}")}
      _ -> {:error, head_cs}
    end
  end

  defp update_location_default_changeset_pipe(%Location{} = location, attrs, _prefix) do
    location
    |> Location.changeset(attrs)
  end

  def update_active_status_for_location(%Location{} = location, location_params, prefix) do
    case location_params do
      %{"active" => false} ->
        deactivate_children(location, location_params, Location, prefix)

      %{"active" => true} ->
        parent_id = HierarchyManager.parent_id(location)
        handle_hierarchical_activation(location, location_params, Location, prefix, parent_id)
    end
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location, prefix) do
    # Deletes the location and children forcibly
    # TBD: do not allow delete if this location is linked to some other record(s)
    # Add that validation here....
    subtree = HierarchyManager.subtree(location)
    IO.inspect(Repo.delete_all(subtree, prefix: prefix))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  alias Inconn2Service.AssetConfig.Equipment

  @doc """
  Returns the list of equipments.

  ## Examples

      iex> list_equipments()
      [%Equipment{}, ...]

  """
  def list_equipments(site_id, prefix) do
    Equipment
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
  end

  def search_equipments(name_text, site_id, prefix) do
    if String.length(name_text) < 3 do
      []
    else
      search_text = "%" <> name_text <> "%"

      from(e in Equipment, where: e.site_id == ^site_id and ilike(e.name, ^search_text), order_by: e.name)
      |> Repo.all(prefix: prefix)
    end
  end

  def list_equipments(site_id, query_params, prefix) do
    Equipment
    |> Repo.add_active_filter(query_params)
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
  end

  def list_equipments(prefix) do
    Equipment
    |> Repo.all(prefix: prefix)
  end

  def list_equipments_tree(site_id, prefix) do
    list_equipments(site_id, %{"active" => "true"}, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_equipments_leaves(site_id, prefix) do
    ids =
      list_equipments(site_id, %{"active" => "true"}, prefix)
      |> HierarchyManager.leaf_nodes()
      |> MapSet.to_list()

    from(e in Equipment, where: e.id in ^ids) |> Repo.all(prefix: prefix)
  end

  def list_equipments_of_location(location_id, prefix) do
    Equipment
    |> where(location_id: ^location_id)
    |> Repo.all(prefix: prefix)
  end

  def list_equipments_of_location(location_id, query_params, prefix) do
    Equipment
    |> Repo.add_active_filter(query_params)
    |> where(location_id: ^location_id)
    |> Repo.all(prefix: prefix)
  end

  def list_equipments_qr(site_id, prefix) do
    equipment = list_equipments(site_id, prefix)
    Enum.map(equipment, fn e ->
      %{
        id: e.id,
        asset_name: e.name,
        asset_code: e.equipment_code,
        asset_qr_url: "/api/equipments/#{e.id}/qr_code"
      }
    end)
  end

  def list_locations_qr(site_id, prefix) do
    locations = list_locations(site_id, prefix)
    Enum.map(locations, fn l ->
      %{
        id: l.id,
        asset_name: l.name,
        asset_code: l.location_code,
        asset_qr_url: "/api/locations/#{l.id}/qr_code"
      }
    end)
  end



  def location_path_of_equipments(equipment_id, prefix) do
    equipment = get_equipment!(equipment_id, prefix)
    site = get_site!(equipment.site_id, prefix)
    location = get_location!(equipment.location_id, prefix)
    query = HierarchyManager.ancestors(location)
    if query != [] do
      [site] ++ Repo.all(query, prefix: prefix) ++ [location]
    else
      [site] ++ [location]
    end
  end
  @doc """
  Gets a single equipment.

  Raises `Ecto.NoResultsError` if the Equipment does not exist.

  ## Examples

      iex> get_equipment!(123)
      %Equipment{}

      iex> get_equipment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment!(id, prefix), do: Repo.get!(Equipment, id, prefix: prefix)
  def get_equipment(id, prefix), do: Repo.get(Equipment, id, prefix: prefix)

  def get_equipment_qr_code(id, prefix) do
    equipment = get_equipment(id, prefix)
    {EQRCode.encode("E:" <> equipment.qr_code) |> EQRCode.png, equipment}
  end

  def get_equipment_by_qr_code(qr_code, prefix), do: Repo.get_by(Equipment, [qr_code: qr_code], prefix: prefix)

  @spec get_root_equipments(any, any) :: any
  def get_root_equipments(site_id, prefix) do
    root_path = []

    query =
      from(e in Equipment,
        where: fragment("(?) = ?", field(e, :path), ^root_path) and e.site_id == ^site_id
      )

    Repo.all(query, prefix: prefix)
  end

  def get_parent_of_equipment(equipment_id, prefix) do
    eq = get_equipment!(equipment_id, prefix)
    HierarchyManager.parent(eq) |> Repo.one(prefix: prefix)
  end

  @doc """
  Creates a equipment.

  ## Examples

      iex> create_equipment(%{field: value})
      {:ok, %Equipment{}}

      iex> create_equipment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment(attrs \\ %{}, prefix) do
    parent_id = Map.get(attrs, "parent_id", nil)

    eq_cs =
      %Equipment{}
      |> Equipment.changeset(attrs)
      |> check_asset_category_type_eq(prefix)
      |> check_site_id_of_location(prefix)

    result = create_equipment_in_tree(parent_id, eq_cs, prefix)

    case result do
      {:ok, equipment} ->
        create_track_for_asset_status(equipment, "E", prefix)

      _ ->
        result
    end

  end

  defp create_equipment_in_tree(nil, eq_cs, prefix) do
    Repo.insert(eq_cs, prefix: prefix)
  end

  defp create_equipment_in_tree(parent_id, eq_cs, prefix) do
    case Repo.get(Equipment, parent_id, prefix: prefix) do
      nil ->
        add_error(eq_cs, :parent_id, "Parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        eq_cs
        |> HierarchyManager.make_child_of(parent)
        |> Repo.insert(prefix: prefix)
    end
  end

  defp check_asset_category_type_eq(eq_cs, prefix) do
    ac_id = get_change(eq_cs, :asset_category_id, nil)

    if ac_id != nil do
      asset_category = Repo.get(AssetCategory, ac_id, prefix: prefix)

      case asset_category.asset_type != "E" do
        true ->
          add_error(eq_cs, :asset_category_id, "Asset category should be equipment")

        false ->
          eq_cs
      end
    else
      eq_cs
    end
  end

  defp check_site_id_of_location(eq_cs, prefix) do
    loc_id = get_field(eq_cs, :location_id, nil)
    site_id = get_field(eq_cs, :site_id, nil)
    if loc_id != nil and site_id != nil do
      location = Repo.get(Location, loc_id, prefix: prefix)
      case site_id != location.site_id do
        true -> add_error(eq_cs, :location_id, "Site Id of location doesn't match Site Id of equipment")
        false -> eq_cs
      end
    else
      eq_cs
    end
  end
  @doc """
  Updates a equipment.

  ## Examples

      iex> update_equipment(equipment, %{field: new_value})
      {:ok, %Equipment{}}

      iex> update_equipment(equipment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment(%Equipment{} = equipment, attrs, prefix, user \\ %{}) do
    existing_parent_id = HierarchyManager.parent_id(equipment)

    result =
      cond do
        Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
          new_parent_id = attrs["parent_id"]

          eq_cs =
            update_equipment_default_changeset_pipe(equipment, attrs, prefix)
            |> check_asset_category_type_eq(prefix)
            |> check_site_id_of_location(prefix)

          update_equipment_in_tree(new_parent_id, eq_cs, equipment, prefix)

        true ->
          eq_cs =
            update_equipment_default_changeset_pipe(equipment, attrs, prefix)
            |> check_asset_category_type_eq(prefix)
            |> check_site_id_of_location(prefix)

          Repo.update(eq_cs, prefix: prefix)
      end

    case result do
      {:ok, updated_equipment} ->
        update_status_track_for_asset(updated_equipment, equipment.status, "E", user, prefix)

      _ ->
        result
    end

    create_status_track_for_asset(result, equipment, attrs, "E", user, prefix)
  end

  def update_active_status_for_equipment(%Equipment{} = equipment, equipment_params, prefix) do
    case equipment_params do
      %{"active" => false} ->
        deactivate_children(equipment, equipment_params, Equipment, prefix)
      %{"active" => true} ->
        parent_id = HierarchyManager.parent_id(equipment)
        handle_hierarchical_activation(equipment, equipment_params, Equipment, prefix, parent_id)
    end
  end

  def validate_parent_active_status(cs, prefix) do
    parent_id = get_field(cs, :parent_id, prefix: prefix)
    if parent_id != nil do
      parent_equipment = Repo.get(Equipment, parent_id)
      case parent_equipment.active do
        false ->
          add_error(cs, :active, "Parent Equipment is not active")
        _ ->
          cs
      end
    else
      cs
    end
  end

  defp update_equipment_in_tree(nil, eq_cs, equipment, prefix) do
    descendents = HierarchyManager.descendants(equipment) |> Repo.all(prefix: prefix)
    # adjust the path (from old path to ne path )for all descendents
    eq_cs = change(eq_cs, %{path: []})
    make_equipments_changeset_and_update(eq_cs, equipment, descendents, [], prefix)
  end

  defp update_equipment_in_tree(new_parent_id, eq_cs, equipment, prefix) do
    # Get the new parent and check
    case Repo.get(Equipment, new_parent_id, prefix: prefix) do
      nil ->
        add_error(eq_cs, :parent_id, "New parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        # Get the descendents
        descendents = HierarchyManager.descendants(equipment) |> Repo.all(prefix: prefix)
        new_path = parent.path ++ [parent.id]
        # make this node child of new parent
        head_cs = HierarchyManager.make_child_of(eq_cs, parent)
        make_equipments_changeset_and_update(head_cs, equipment, descendents, new_path, prefix)
    end
  end

  defp make_equipments_changeset_and_update(head_cs, equipment, descendents, new_path, prefix) do
    # adjust the path (from old path to ne path )for all descendents
    multi =
      [
        {equipment.id, head_cs}
        | Enum.map(descendents, fn d ->
            {_, rest} = Enum.split_while(d.path, fn e -> e != equipment.id end)
            {d.id, Equipment.changeset(d, %{}) |> change(%{path: new_path ++ rest})}
          end)
      ]
      |> Enum.reduce(Multi.new(), fn {indx, cs}, multi ->
        Multi.update(multi, :"equipment#{indx}", cs, prefix: prefix)
      end)

    case Repo.transaction(multi, prefix: prefix) do
      {:ok, eq} -> {:ok, Map.get(eq, :"equipment#{equipment.id}")}
      _ -> {:error, head_cs}
    end
  end

  defp update_equipment_default_changeset_pipe(%Equipment{} = equipment, attrs, _prefix) do
    equipment
    |> Equipment.changeset(attrs)
  end

  @doc """
  Deletes a equipment.

  ## Examples

      iex> delete_equipment(equipment)
      {:ok, %Equipment{}}

      iex> delete_equipment(equipment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment(%Equipment{} = equipment, prefix) do
    # Deletes the equipment and children forcibly
    # TBD: do not allow delete if this equipment is linked to some other record(s)
    # Add that validation here....
    subtree = HierarchyManager.subtree(equipment)
    Repo.delete_all(subtree, prefix: prefix)
  end

  def get_asset_by_type(asset_id, asset_type, prefix) do
    case asset_type do
      "L" ->
        get_location(asset_id, prefix)

      "E" ->
        get_equipment(asset_id, prefix)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment changes.

  ## Examples

      iex> change_equipment(equipment)
      %Ecto.Changeset{data: %Equipment{}}

  """
  def change_equipment(%Equipment{} = equipment, attrs \\ %{}) do
    Equipment.changeset(equipment, attrs)
  end


  def get_asset_from_qr_code(qr_code, prefix) do
    [asset_type, uuid] = String.split(qr_code, ":")
    case asset_type do
      "L" -> {"L", get_location_by_qr_code(uuid, prefix) |> Map.put(:asset_type, "L") |> preload_site_and_location(prefix)}
      "E" -> {"E", get_equipment_by_qr_code(uuid, prefix) |> Map.put(:asset_type, "E") |> preload_site_and_location(prefix)}
    end
  end

  def preload_site_and_location(asset, prefix) do
    site = get_site!(asset.site_id, prefix)
    case asset.asset_type do
      "L" ->
         asset |> Map.put(:location_id, asset.id) |> Map.put(:location_name, asset.name) |> Map.put(:site_name, site.name)

      "E" ->
        location = get_location!(asset.location_id, prefix)
         asset |> Map.put(:location_id, asset.location_id) |> Map.put(:location_name, location.name) |> Map.put(:site_name, site.name)
    end
  end

  alias Inconn2Service.AssetConfig.Party

  @doc """
  Returns the list of parties.

  ## Examples

      iex> list_parties()
      [%Party{}, ...]

  """
  def list_parties(prefix) do
    Repo.all(Party, prefix: prefix)
  end

  def list_parties(query_params, prefix) do
    Party
    |> Repo.add_active_filter(query_params)
    |> Repo.all(prefix: prefix)
  end

  def list_SP(prefix) do
    query =
      from(p in Party,
        where:
          p.party_type ==
            "SP"
      )

    Repo.all(query, prefix: prefix)
  end

  def list_AO(prefix) do
    query =
      from(p in Party,
        where:
          p.allowed_party_type ==
            "AO"
      )

    Repo.all(query, prefix: prefix)
  end

  @doc """
  Gets a single party.

  Raises `Ecto.NoResultsError` if the Party does not exist.

  ## Examples

      iex> get_party!(123)
      %Party{}

      iex> get_party!(456)
      ** (Ecto.NoResultsError)

  """
  def get_party!(id, prefix), do: Repo.get!(Party, id, prefix: prefix)

  def get_party_AO_self(id, prefix) do
    party_type_AO = "AO"
    licensee = true
    # checking in party table for Asset Owner with licensee Y given party id to create a site
    query =
      from(p in Party,
        where: p.id == ^id and p.party_type == ^party_type_AO and p.licensee == ^licensee
      )

    IO.inspect(Repo.one(query, prefix: prefix))
  end

  def get_party_AO(id, prefix) do
    org_type_AO = "AO"
    # checking in party table for Asset Owner with licensee Y given party id to create a site
    query =
      from(p in Party,
        where: p.id == ^id and (p.party_type == ^org_type_AO)
      )

    Repo.one(query, prefix: prefix)
  end

  def check_party_with_licensee(id, prefix) do
    licensee = true

    query =
      from(p in Party,
        where:
          p.id == ^id and
            p.licensee == ^licensee
      )

    Repo.one(query, prefix: prefix)
  end

  def get_party_licensee_AO(prefix) do
    # If if there exisit one record that was created automatically
    # with licensee id, Asset owner and self servicing. More than one record should not be allowed to be created
    query =
      from(p in Party,
        where:
          p.party_type == "AO" and
            p.licensee == true
      )

    Repo.one(query, prefix: prefix)
  end

  def get_party_licensee_SP(prefix) do
    # If if there exisit one record that was created automatically
    # with licensee id, Asset owner and self servicing. More than one record should not be allowed to be created
    query =
      from(p in Party,
        where:
          p.party_type == "SP" and
            p.licensee == true
      )

    Repo.one(query, prefix: prefix)
  end

  @doc """
  Creates a party.

  ## Examples

      iex> create_party(%{field: value})
      {:ok, %Party{}}

      iex> create_party(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_default_party(licensee_set, prefix) do
    company_name = IO.inspect(licensee_set.company_name)
    party_type = IO.inspect(licensee_set.party_type)
    address = IO.inspect(licensee_set.address)
    contact = IO.inspect(licensee_set.contact)
    IO.inspect(party_type)
    licensee = check_licensee(party_type)
    IO.inspect(licensee)
    # check_licensee(party_type)

    returnMap = %{
      "company_name" => company_name,
      "party_type" => party_type,
      "licensee" => licensee,
      "address" => %{
        "address_line1" => address.address_line1,
        "address_line2" => address.address_line2,
        "city" => address.city,
        "state" => address.state,
        "country" => address.country,
        "postcode" => address.postcode
      },
      "contact" => %{
        "first_name" => contact.first_name,
        "last_name" => contact.last_name,
        "designation" => contact.designation,
        "land_line" => contact.land_line,
        "mobile" => contact.mobile,
        "email" => contact.email
      }
    }

    %Party{}
    |> Party.changeset(returnMap)
    |> Repo.insert(prefix: prefix)
  end

  defp check_licensee(party_type) do
    cond do
      party_type == "AO" ->
        true

      party_type == "SP" ->
        true
    end
  end

  def create_party(attrs \\ %{}, prefix) do
    %Party{}
    |> Party.changeset(attrs)
    |> validate_party(attrs, prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp validate_party(cs, attrs, prefix) do
    case Map.get(attrs, "party_type") do
      "SP" ->
            sp_party = get_party_licensee_SP(prefix)
            if sp_party == nil do
              change(cs, %{licensee: false})
            else
              add_error(cs, :party_type, "Cannot create more parties as Service Provider")
            end

      "AO" ->
            ao_party = get_party_licensee_AO(prefix)
            if ao_party == nil do
              change(cs, %{licensee: false})
            else
              add_error(cs, :party_type, "Cannot create more parties as Asset Owner")
            end
       _ ->
            cs
    end
  end

  @doc """
  Updates a party.

  ## Examples

      iex> update_party(party, %{field: new_value})
      {:ok, %Party{}}

      iex> update_party(party, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_party(%Party{} = party, attrs, prefix) do
    party
    |> Party.changeset(attrs)
    |> validate_party(attrs, prefix)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a party.

  ## Examples

      iex> delete_party(party)
      {:ok, %Party{}}

      iex> delete_party(party)
      {:error, %Ecto.Changeset{}}

  """
  def delete_party(%Party{} = party, prefix) do
    Repo.delete(party, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking party changes.

  ## Examples

      iex> change_party(party)
      %Ecto.Changeset{data: %Party{}}

  """
  def change_party(%Party{} = party, attrs \\ %{}) do
    Party.changeset(party, attrs)
  end

  defp create_track_for_asset_status(asset, asset_type, prefix, user_id \\ nil) do
    time_zone = get_site_time_zone_from_asset(asset.site_id, prefix)
    {:ok, date_time} = DateTime.now(time_zone)

    attrs = %{
      "asset_id" => asset.id,
      "asset_type" => asset_type,
      "changed_date_time" => DateTime.to_naive(date_time),
      "status_changed" => asset.status,
      "user_id" => user_id
    }
    create_asset_status_track(attrs, prefix)

    {:ok, asset}
  end

  def get_site_time_zone_from_asset(site_id, prefix) do
    site = get_site!(site_id, prefix)
    site.time_zone
  end

  defp handle_hierarchical_activation(resource, resource_params, module, prefix, parent_id) do
    resource
    |> module.changeset(resource_params)
    |> validate_parent_for_true_condition(module, prefix, parent_id)
    |> Repo.update(prefix: prefix)
    |> update_children(prefix)
  end

  defp deactivate_children(resource, resource_params, module, prefix) do
    descendants = HierarchyManager.descendants(resource)
    Repo.update_all(descendants, [set: [active: false]], prefix: prefix)
    resource |> module.changeset(resource_params) |> Repo.update(prefix: prefix)
  end

  defp validate_parent_for_true_condition(cs, module, prefix, parent_id) do
    # parent_id = get_field(cs, :parent_id, nil)
    IO.inspect("Parent Id is #{parent_id}")
    if parent_id != nil do
      parent = Repo.get(module, parent_id, prefix: prefix)
      if parent != nil do
        case parent.active do
          false -> add_error(cs, :parent_id, "Parent Not Active")
          _ -> cs
        end
      else
        add_error(cs, :parent_id, "Parent Not Found")
      end
    else
      cs
    end
  end

  defp update_children({:ok, resource}, prefix) do
    descendants = HierarchyManager.descendants(resource)
    Repo.update_all(descendants, [set: [active: true]], prefix: prefix)
    {:ok, resource}
  end

  defp update_children({:error, cs}, _prefix), do: {:error, cs}


  alias Inconn2Service.AssetConfig.AssetStatusTrack

  @doc """
  Returns the list of asset_status_tracks.

  ## Examples

      iex> list_asset_status_tracks()
      [%AssetStatusTrack{}, ...]

  """
  def list_asset_status_tracks(prefix) do
    Repo.all(AssetStatusTrack, prefix: prefix)
  end

  @doc """
  Gets a single asset_status_track.

  Raises `Ecto.NoResultsError` if the Asset status track does not exist.

  ## Examples

      iex> get_asset_status_track!(123)
      %AssetStatusTrack{}

      iex> get_asset_status_track!(456)
      ** (Ecto.NoResultsError)

  """
  def get_asset_status_track!(id, prefix), do: Repo.get!(AssetStatusTrack, id, prefix: prefix)

  @doc """
  Creates a asset_status_track.

  ## Examples

      iex> create_asset_status_track(%{field: value})
      {:ok, %AssetStatusTrack{}}

      iex> create_asset_status_track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_asset_status_track(attrs \\ %{}, prefix) do
    %AssetStatusTrack{}
    |> AssetStatusTrack.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a asset_status_track.

  ## Examples

      iex> update_asset_status_track(asset_status_track, %{field: new_value})
      {:ok, %AssetStatusTrack{}}

      iex> update_asset_status_track(asset_status_track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_asset_status_track(%AssetStatusTrack{} = asset_status_track, attrs, prefix) do
    asset_status_track
    |> AssetStatusTrack.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a asset_status_track.

  ## Examples

      iex> delete_asset_status_track(asset_status_track)
      {:ok, %AssetStatusTrack{}}

      iex> delete_asset_status_track(asset_status_track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_asset_status_track(%AssetStatusTrack{} = asset_status_track, prefix) do
    Repo.delete(asset_status_track, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking asset_status_track changes.

  ## Examples

      iex> change_asset_status_track(asset_status_track)
      %Ecto.Changeset{data: %AssetStatusTrack{}}

  """
  def change_asset_status_track(%AssetStatusTrack{} = asset_status_track, attrs \\ %{}) do
    AssetStatusTrack.changeset(asset_status_track, attrs)
  end

  alias Inconn2Service.AssetConfig.SiteConfig

  @doc """
  Returns the list of site_config.

  ## Examples

      iex> list_site_config()
      [%SiteConfig{}, ...]

  """
  def list_site_config(prefix) do
    Repo.all(SiteConfig, prefix: prefix)
  end

  @doc """
  Gets a single site_config.

  Raises `Ecto.NoResultsError` if the Site config does not exist.

  ## Examples

      iex> get_site_config!(123)
      %SiteConfig{}

      iex> get_site_config!(456)
      ** (Ecto.NoResultsError)

  """
  def get_site_config!(id, prefix), do: Repo.get!(SiteConfig, id, prefix: prefix)
  def get_site_config_by_site_id(site_id, prefix) do
    Repo.get_by(SiteConfig, [site_id: site_id], prefix: prefix)
  end

  @doc """
  Creates a site_config.

  ## Examples

      iex> create_site_config(%{field: value})
      {:ok, %SiteConfig{}}

      iex> create_site_config(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_site_config(attrs \\ %{}, prefix) do
    %SiteConfig{}
    |> SiteConfig.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a site_config.

  ## Examples

      iex> update_site_config(site_config, %{field: new_value})
      {:ok, %SiteConfig{}}

      iex> update_site_config(site_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_site_config(%SiteConfig{} = site_config, attrs, prefix) do
    attrs = append_in_config(attrs, site_config)
    site_config
    |> SiteConfig.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  defp append_in_config(attrs, site_config) do
    config = attrs["config"]
    old_config = site_config.config
    new_config = Enum.reduce(config, old_config, fn x, acc -> Map.put(acc, elem(x, 0), elem(x, 1)) end)
    Map.put(attrs, "config", new_config)
  end
  @doc """
  Deletes a site_config.

  ## Examples

      iex> delete_site_config(site_config)
      {:ok, %SiteConfig{}}

      iex> delete_site_config(site_config)
      {:error, %Ecto.Changeset{}}

  """
  def delete_site_config(%SiteConfig{} = site_config, prefix) do
    Repo.delete(site_config, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site_config changes.

  ## Examples

      iex> change_site_config(site_config)
      %Ecto.Changeset{data: %SiteConfig{}}

  """
  def change_site_config(%SiteConfig{} = site_config, attrs \\ %{}) do
    SiteConfig.changeset(site_config, attrs)
  end
end

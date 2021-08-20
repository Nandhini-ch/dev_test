defmodule Inconn2Service.AssetConfig do
  @moduledoc """
  The AssetConfig context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Multi
  alias Inconn2Service.Repo

  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.Util.HierarchyManager

  @doc """
  Returns the list of sites.

  ## Examples

      iex> list_sites()
      [%Site{}, ...]

  """
  def list_sites(prefix) do
    Repo.all(Site, prefix: prefix)
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
    %Site{}
    |> Site.changeset(attrs)
    |> Repo.insert(prefix: prefix)
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

  def list_locations_tree(site_id, prefix) do
    list_locations(site_id, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_locations_leaves(site_id, prefix) do
    ids = list_locations(site_id, prefix)
          |> HierarchyManager.leaf_nodes()
          |> MapSet.to_list()
    from(a in Location, where: a.id in ^ids ) |> Repo.all(prefix: prefix)
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

    create_location_in_tree(parent_id, loc_cs, prefix)
  end

  defp create_location_in_tree(nil, loc_cs, prefix) do
    Repo.insert(loc_cs, prefix: prefix)
  end

  defp create_location_in_tree(parent_id, loc_cs, prefix) do
    case Repo.get(Location, parent_id, prefix: prefix) do
      nil ->
        add_error(loc_cs, :parent_id, "Parent object does not exist")

      parent ->
        loc_cs
        |> HierarchyManager.make_child_of(parent)
        |> Repo.insert(prefix: prefix)
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
  def update_location(%Location{} = location, attrs, prefix) do
    existing_parent_id = HierarchyManager.parent_id(location)

    cond do
      Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
        new_parent_id = attrs["parent_id"]
        loc_cs = update_location_default_changeset_pipe(location, attrs, prefix)
        update_location_in_tree(new_parent_id, loc_cs, location, prefix)

      true ->
        update_location_default_changeset_pipe(location, attrs, prefix)
        |> Repo.update(prefix: prefix)
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
    Repo.delete_all(subtree, prefix: prefix)
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


  alias Inconn2Service.AssetConfig.AssetCategory

  @doc """
  Returns the list of asset_categories.

  ## Examples

      iex> list_asset_categories()
      [%AssetCategory{}, ...]

  """
  def list_asset_categories(site_id, prefix) do
    AssetCategory
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories_tree(site_id, prefix) do
    list_asset_categories(site_id, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_asset_categories_leaves(site_id, prefix) do
    ids = list_asset_categories(site_id, prefix)
          |> HierarchyManager.leaf_nodes()
          |> MapSet.to_list()
    from(a in AssetCategory, where: a.id in ^ids ) |> Repo.all(prefix: prefix)
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
      attrs = add_or_change_asset_type(attrs, parent_id, prefix)
      create_asset_category_with_asset_type(attrs, parent_id,prefix)
    else
      create_asset_category_with_asset_type(attrs, parent_id,prefix)
    end
  end

  defp create_asset_category_with_asset_type(attrs, parent_id,prefix) do
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

      parent ->
        Repo
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
        attrs = add_or_change_asset_type(attrs, new_parent_id, prefix)
        ac_cs = update_asset_category_default_changeset_pipe(asset_category, attrs, prefix)
        update_asset_category_in_tree(new_parent_id, ac_cs, asset_category, prefix)

      true ->
        attrs = add_or_change_asset_type(attrs, existing_parent_id, prefix)
        update_asset_category_default_changeset_pipe(asset_category, attrs, prefix)
        |> Repo.update(prefix: prefix)

    end
  end

  defp add_or_change_asset_type(attrs, parent_id, prefix) do
    parent = get_asset_category!(parent_id, prefix)
    Map.put(attrs, "asset_type", parent.asset_type)
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

      parent ->
        # Get the descendents
        descendents = HierarchyManager.descendants(asset_category) |> Repo.all(prefix: prefix)
        new_path = parent.path ++ [parent.id]
        # make this node child of new parent
        head_cs = HierarchyManager.make_child_of(ac_cs, parent)
        make_asset_categories_changeset_and_update(head_cs, asset_category, descendents, new_path, prefix)
    end
  end

  defp make_asset_categories_changeset_and_update(head_cs, asset_category, descendents, new_path, prefix) do
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

  defp update_asset_category_default_changeset_pipe(%AssetCategory{} = asset_category, attrs, _prefix) do
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
end

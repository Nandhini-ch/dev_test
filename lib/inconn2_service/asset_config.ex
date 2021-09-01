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
  Inconn2Service.Account.Licensee

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

  def list_asset_categories_tree(prefix) do
    list_asset_categories(prefix)
    |> HierarchyManager.build_tree()
  end

  def list_asset_categories_leaves(prefix) do
    ids =
      list_asset_categories(prefix)
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

  defp add_or_change_asset_type_new_parent(attrs, new_parent_id, prefix) do
    parent = Repo.get(AssetCategory, new_parent_id, prefix: prefix)

    if parent != nil do
      Map.put(attrs, "asset_type", parent.asset_type)
    else
      attrs
    end
  end

  defp add_or_change_asset_type(attrs, asset_category, _prefix) do
    parent = HierarchyManager.parent(asset_category)

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

  def list_locations_tree(site_id, prefix) do
    list_locations(site_id, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_locations_leaves(site_id, prefix) do
    ids =
      list_locations(site_id, prefix)
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

    create_location_in_tree(parent_id, loc_cs, prefix)
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

      case asset_category.asset_type != "L" do
        true ->
          add_error(loc_cs, :asset_category_id, "Asset category should be location")

        false ->
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
  def update_location(%Location{} = location, attrs, prefix) do
    existing_parent_id = HierarchyManager.parent_id(location)

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

  def list_equipments_tree(site_id, prefix) do
    list_equipments(site_id, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_equipments_leaves(site_id, prefix) do
    ids =
      list_equipments(site_id, prefix)
      |> HierarchyManager.leaf_nodes()
      |> MapSet.to_list()

    from(e in Equipment, where: e.id in ^ids) |> Repo.all(prefix: prefix)
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

    create_equipment_in_tree(parent_id, eq_cs, prefix)
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

  @doc """
  Updates a equipment.

  ## Examples

      iex> update_equipment(equipment, %{field: new_value})
      {:ok, %Equipment{}}

      iex> update_equipment(equipment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment(%Equipment{} = equipment, attrs, prefix) do
    existing_parent_id = HierarchyManager.parent_id(equipment)

    cond do
      Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
        new_parent_id = attrs["parent_id"]

        eq_cs =
          update_equipment_default_changeset_pipe(equipment, attrs, prefix)
          |> check_asset_category_type_eq(prefix)

        update_equipment_in_tree(new_parent_id, eq_cs, equipment, prefix)

      true ->
        eq_cs =
          update_equipment_default_changeset_pipe(equipment, attrs, prefix)
          |> check_asset_category_type_eq(prefix)

        Repo.update(eq_cs, prefix: prefix)
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment changes.

  ## Examples

      iex> change_equipment(equipment)
      %Ecto.Changeset{data: %Equipment{}}

  """
  def change_equipment(%Equipment{} = equipment, attrs \\ %{}) do
    Equipment.changeset(equipment, attrs)
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
    licensee = true
    # checking in party table for Asset Owner with licensee Y given party id to create a site
    query =
      from(p in Party,
        where: p.id == ^id and (p.party_type == ^org_type_AO and p.licensee == ^licensee)
      )

    IO.inspect(Repo.one(query, prefix: prefix))
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
    _address = IO.inspect(licensee_set.address)
    _contact = IO.inspect(licensee_set.contact)
    IO.inspect(party_type)
    licensee = check_licensee(party_type)
    IO.inspect(licensee)
    # check_licensee(party_type)

    returnMap = %{
      "company_name" => company_name,
      "party_type" => party_type,
      "licensee" => licensee
      # "address" => address,
      # "contact" => contact
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
    # licensee id
    # service_id = Map.get(attrs, "service_id")
    party_type = Map.get(attrs, "party_type")
    # allowed_party_type = Map.get(attrs, "allowed_party_type")
    # create_party = Map.get(attrs, "create_party")
    # licensee = Map.get(attrs, "licensee")

    # If if there exisit one record that was created automatically
    # with licensee id, Asset owner and self servicing. More than one record
    # should not be allowed to be created

    if party_type == "SP" do
      sp_part = get_party_licensee_SP(prefix)

      case sp_part do
        nil ->
          # if no record for SP and licensee Y then create new record
          %Party{}
          |> Party.changeset(attrs)
          |> change(%{licensee: false})
          |> Repo.insert(prefix: prefix)

        {:ok, change_set} ->
          add_error(
            change_set,
            :party_id,
            "Cannot create more parties for Service Providers"
          )

        {:error, change_set} ->
          change_set

        change_set ->
          add_error(
            change_set,
            :party_id,
            "Cannot create more parties for Service Providers"
          )
      end
    end

    if party_type == "AO" do
      party = get_party_licensee_AO(prefix)

      case party do
        nil ->
          # if no record for AO and licensee Y then check if it is an SP with license
          %Party{}
          |> Party.changeset(attrs)
          |> change(%{licensee: false})
          |> Repo.insert(prefix: prefix)

        {:ok, change_set} ->
          add_error(
            change_set,
            :party_id,
            "Cannot create more parties for Asset Owner"
          )

        {:error, change_set} ->
          change_set

        change_set ->
          add_error(
            change_set,
            :party_id,
            "Cannot create more parties for Asset Owner"
          )
      end
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
end

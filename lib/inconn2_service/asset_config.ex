defmodule Inconn2Service.AssetConfig do

  import Ecto.Query, warn: false
  import Ecto.Changeset
  import Inconn2Service.Util.DeleteManager
  import Inconn2Service.Util.IndexQueries
  import Inconn2Service.Util.HelpersFunctions
  import Inconn2Service.Prompt

  alias Ecto.Multi
  alias Inconn2Service.Repo

  alias Inconn2Service.Staff.User
  alias Inconn2Service.Staff
  alias Inconn2Service.AssetConfig.{AssetStatusTrack, Equipment, Location, Site, Zone}
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.Custom.CustomFields
  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.AssetConfig.Party
  alias Inconn2Service.ContractManagement.{Contract, Scope}

  def list_zones(prefix) do
    Zone
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def get_zone!(id, prefix), do: Repo.get!(Zone, id, prefix: prefix)

  def get_zone_subtree_ids(nil, prefix) do
    list_zones(prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def get_zone_subtree_ids(zone_id, prefix) do
    zone_id
    |> get_zone!(prefix)
    |> HierarchyManager.subtree()
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def create_zone(attrs \\ %{}, prefix) do
    parent_id = Map.get(attrs, "parent_id", nil)

    zone_cs =
    %Zone{}
    |> Zone.changeset(attrs)
    create_zone_in_tree(parent_id, zone_cs, prefix)
  end

  def list_zone_tree(prefix) do
    list_zones(prefix)
    |> HierarchyManager.build_tree()
  end

  def update_zone(%Zone{} = zone, attrs, prefix) do
    existing_parent_id = HierarchyManager.parent_id(zone)
      cond do
        Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
          new_parent_id = attrs["parent_id"]

          zone_cs = change_zone(zone, attrs)
          update_zone_in_tree(new_parent_id, zone_cs, zone, prefix)
        true ->
          change_zone(zone, attrs)
          |> Repo.update(prefix: prefix)

      end
  end

  # def delete_zone(%Zone{} = zone, prefix) do
  #   # Deletes the zone and children forcibly
  #   # TBD: do not allow delete if this zone is linked to some other record(s)
  #   # Add that validation here....
  #   HierarchyManager.subtree(zone)
  #   |> Repo.delete_all(prefix: prefix)
  # end

  def delete_zone(%Zone{} = zone, prefix) do
    cond do
      has_descendants?(zone, prefix) ->
        {
          :could_not_delete,
          "Cannot be deleted as there are descendants to this zone"
        }
      has_site?(zone, prefix) ->
        {
          :could_not_delete,
          "Cannot be deleted as there are site associated with this zone or its descendants"
        }
      true ->
        update_zone(zone, %{"active" => false}, prefix)
        {:deleted, "Zone was deleted"}
    end
  end

  def change_zone(%Zone{} = zone, attrs \\ %{}) do
    Zone.changeset(zone, attrs)
  end

  def list_sites(query_params \\ %{}, prefix) do
   Site
   |> site_query(query_params, prefix)
   |> Repo.add_active_filter()
   |> Repo.all(prefix: prefix)
   |> Repo.sort_by_id()
  end

  def list_sites_for_user(user, prefix) do
    case get_party!(user.party_id, prefix).party_type do
      "AO" -> list_sites(%{"party_id" => user.party_id}, prefix)
      "SP" -> list_sites_by_contract_and_manpower(user.party_id, prefix)
    end
  end

  def list_sites_by_contract_and_manpower(party_id, prefix) do
    from(c in Contract, where: c.party_id == ^party_id,
      join: sc in Scope, on: c.id == sc.contract_id,
      join: s in Site, on: s.id == sc.site_id,
      select: s)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.uniq()
    |> Repo.sort_by_id()
  end

  def get_site!(id, prefix), do: Repo.get!(Site, id, prefix: prefix)
  def get_site(id, prefix), do: Repo.get(Site, id, prefix: prefix)

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

      case result do
        nil ->
          site =
            %Site{}
            |> Site.changeset(attrs)
            |> add_error(:party_id, "Cannot create site, There is no Licensee / Party - Asset owner for this site")
            |> Repo.insert(prefix: prefix)


        {:error, change_set} ->
          IO.inspect(change_set)
          change_set

        _change_set ->
          site =
            %Site{}
            |> Site.changeset(attrs)
            |> Repo.insert(prefix: prefix)
      end
    end
  end

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

  def delete_site(%Site{} = site, prefix) do
    cond do
      has_equipment?(site, prefix) ->
         {:could_not_delete,
           "Cannot be deleted as there are Equipments associated with it"
         }

      has_location?(site, prefix) ->
         {:could_not_delete,
           "Cannot be deleted as there are Location associated with it"
         }

      has_employee_rosters?(site, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are Employee Roster associated with it"
         }

      has_shift?(site, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Shift associated with it"
        }

      has_store?(site, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are Store associated with it"
        }

      has_manpower_configuration?(site, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Manpower configuration associated with it"
        }

      true ->
       update_site(site, %{"active" => false}, prefix)
         {:deleted,
            "The site was disabled"
          }
    end
  end

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

  def list_asset_categories(prefix) do
    AssetCategory
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories(_query_params, prefix) do
    AssetCategory
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories_by_type(type, prefix) do
    AssetCategory
    |> where(asset_type: ^type)
    |> Repo.all(prefix: prefix)
  end

  def list_asset_categories_by_type(type, _query_params, prefix) do
    AssetCategory
    |> Repo.add_active_filter()
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

  def get_asset_category_subtree_ids(nil, prefix) do
    AssetCategory
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def get_asset_category_subtree_ids(asset_category_id, prefix) do
    asset_category_id
    |> get_asset_category!(prefix)
    |> HierarchyManager.subtree()
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def get_location_subtree_ids(nil, prefix) do
    Location
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def get_location_subtree_ids(location_id, prefix) do
    location_id
    |> get_location!(prefix)
    |> HierarchyManager.subtree()
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def get_equipment_subtree_ids(nil, prefix) do
    Equipment
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def get_equipment_subtree_ids(equipment_id, prefix) do
    equipment_id
    |> get_equipment!(prefix)
    |> HierarchyManager.subtree()
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> Map.fetch!(x, :id) end)
  end

  def get_loc_and_eqp_subtree_ids(asset_id, asset_type, prefix) when not is_nil(asset_id) and not is_nil(asset_type) do
    case asset_type do
      "L" -> get_location_subtree_ids(asset_id, prefix)
      "E" -> get_equipment_subtree_ids(asset_id, prefix)
    end
  end
  def get_loc_and_eqp_subtree_ids(_asset_id, _asset_type, _prefix), do: []

  def list_asset_categories_for_location(location_id, prefix) do
    {locations, equipments} = get_assets_for_location(location_id, prefix)

    locations ++ equipments
    |> Stream.map(&(&1.asset_category_id))
    |> Enum.uniq()
    |> get_asset_category_by_ids(prefix)
  end

  def list_asset_categories_tree_for_location(location_id, prefix) do
    list_asset_categories_for_location(location_id, prefix)
    |> HierarchyManager.build_tree()
  end

  def get_asset_category!(id, prefix), do: Repo.get!(AssetCategory, id, prefix: prefix)
  def get_asset_category(id, prefix), do: Repo.get(AssetCategory, id, prefix: prefix)
  def get_asset_category_by_ids(ids, prefix) do
    from(ac in AssetCategory, where: ac.id in ^ids)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

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

  def get_assets(id, prefix) do
    asset_category = get_asset_category!(id, prefix)
    asset_type = asset_category.asset_type
    subtree = HierarchyManager.subtree(asset_category) |> Repo.add_active_filter() |> Repo.all(prefix: prefix)
    ids = Enum.map(subtree, fn x -> Map.fetch!(x, :id) end)

    case asset_type do
      "L" -> from(l in Location, where: l.asset_category_id in ^ids) |> Repo.add_active_filter() |> Repo.all(prefix: prefix)
      "E" -> from(e in Equipment, where: e.asset_category_id in ^ids) |> Repo.add_active_filter() |> Repo.all(prefix: prefix)
    end
  end

  def get_asset_by_asset_id(asset_id, asset_type, prefix) do
    case asset_type do
      "L" -> get_location!(asset_id, prefix)
      "E" -> get_equipment!(asset_id, prefix)
    end
  end

  def get_assets(site_id, asset_category_id, prefix) do
    asset_category = get_asset_category!(asset_category_id, prefix)
    asset_type = asset_category.asset_type
    subtree = HierarchyManager.subtree(asset_category) |> Repo.add_active_filter() |> Repo.all(prefix: prefix)
    ids = Enum.map(subtree, fn x -> Map.fetch!(x, :id) end)

    case asset_type do
      "L" -> from(l in Location, where: l.asset_category_id in ^ids and l.site_id == ^site_id) |> Repo.add_active_filter() |> Repo.all(prefix: prefix)
      "E" -> from(e in Equipment, where: e.asset_category_id in ^ids and e.site_id == ^site_id) |> Repo.add_active_filter() |> Repo.all(prefix: prefix)
    end
  end

  def get_asset_count_by_asset_category(asset_category_id, asset_type, prefix) do
       case asset_type do
        "L" -> from(l in Location, where: l.asset_category_id == ^asset_category_id and l.active, select: count(l.id)) |> Repo.one(prefix: prefix)
        "E" -> from(e in Equipment, where: e.asset_category_id == ^asset_category_id and e.active, select: count(e.id)) |> Repo.one(prefix: prefix)
       end
  end

  def create_asset_category(attrs \\ %{}, prefix) do
    parent_id = Map.get(attrs, "parent_id", nil)

    # IO.inspect(String.length(parent_id))

    if parent_id != nil and is_integer(parent_id) do
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

  defp create_asset_category_in_tree("", ac_cs, prefix) do
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

  # def update_active_status_for_asset_category(%AssetCategory{} = asset_category, asset_params, prefix) do
  #   case asset_params do
  #     %{"active" => false} ->
  #       children = HierarchyManager.children(asset_category)
  #       IO.inspect(children)
  #       Repo.update_all(children, [set: [active: false]], prefix: prefix)
  #       asset_category
  #       |> AssetCategory.changeset(asset_params)
  #       |> Repo.update(prefix: prefix)

  #     %{"active" => true} ->
  #       parent_id = HierarchyManager.parent_id(asset_category)
  #       asset_category
  #       |> AssetCategory.changeset(asset_params)
  #       |> validate_parent_for_true_condition(AssetCategory, prefix, parent_id)
  #       |> Repo.update(prefix: prefix)
  #       |> update_children(prefix)
  #   end
  # end

  defp add_or_change_asset_type_new_parent(attrs, new_parent_id, prefix) do
    parent = Repo.get(AssetCategory, new_parent_id, prefix: prefix)

    if parent != nil do
      Map.put(attrs, "asset_type", parent.asset_type)
    else
      attrs
    end
  end

  defp add_or_change_asset_type(attrs, asset_category, prefix) do
    parent_query = HierarchyManager.parent(asset_category)

    parent =
      case parent_query do
       nil -> nil
       query -> query |> Repo.one(prefix: prefix)
      end

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

  #FUnction commented because soft delete is implemented
  # def delete_asset_category(%AssetCategory{} = asset_category, prefix) do
  #   # Deletes the asset_category and children forcibly
  #   # TBD: do not allow delete if this asset_category is linked to some other record(s)
  #   # Add that validation here....
  #   subtree = HierarchyManager.subtree(asset_category)
  #   Repo.delete_all(subtree, prefix: prefix)
  # end

  def delete_asset_category(%AssetCategory{} = asset_category, prefix) do
    cond do
      has_descendants?(asset_category, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the location has descendants"}

      has_workorder_template_ac?(asset_category, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are Workorder template associated with it"}

      has_equipment?(asset_category, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are Equipment associated with it"}

      has_task_list?(asset_category, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are Task list associated with it"}

      has_location?(asset_category, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are Location associated with it"}

      has_descendants?(asset_category, prefix) ->
        {:could_not_delete,
        "could not delete has descendants"}

      true ->
        update_asset_category(asset_category, %{"active" => false}, prefix)
        # deactivate_children(asset_category, AssetCategory, prefix)
        {:deleted,
        "The site was disabled"}
    end
  end

  def change_asset_category(%AssetCategory{} = asset_category, attrs \\ %{}) do
    AssetCategory.changeset(asset_category, attrs)
  end


  alias Inconn2Service.AssetConfig.Location

  def list_locations(site_id, prefix) do
    Location
    |> Repo.add_active_filter()
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def search_locations(name_text, site_id, prefix) do
    if String.length(name_text) < 3 do
      []
    else
      search_text = "%" <> name_text <> "%"

      from(l in Location, where: l.site_id == ^site_id and ilike(l.name, ^search_text), order_by: l.name)
      |> Repo.add_active_filter()
      |> Repo.all(prefix: prefix)
    end
  end

  def list_locations(site_id, _query_params, prefix) do
    Location
    |> Repo.add_active_filter()
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_active_locations(prefix) do
    Location
    |> where(active: true)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_locations_by_ids(ids, prefix) do
    from(l in Location, where: l.id in ^ids)
    |> Repo.add_active_filter()
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

  def get_assets_for_location(location_id, prefix) do
    locations = get_location!(location_id, prefix)
                |> HierarchyManager.subtree()
                |> Repo.add_active_filter()
                |> Repo.all(prefix: prefix)

    equipments = list_equipments_by_location_ids(Enum.map(locations, &(&1.id)), prefix)

    {locations, equipments}
  end

  def get_asset_ids_for_location(location_id, prefix) do
    location_ids = get_location!(location_id, prefix)
                    |> HierarchyManager.subtree()
                    |> get_ids_from_query(prefix)

    equipment_ids = from(e in Equipment, where: e.location_id in ^location_ids)
                    |> get_ids_from_query(prefix)


    get_asset_ids_and_type_map(location_ids, "L") ++
    get_asset_ids_and_type_map(equipment_ids, "E")

  end

  defp get_asset_ids_and_type_map(ids, asset_type), do: Enum.map(ids, fn id -> %{"id" => id, "type" => asset_type} end)

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
        Elixir.Task.start(fn -> push_alert_notification_for_asset(nil, location, location.site_id, prefix) end)
        result
      _ ->
        result
    end
  end

  defp create_location_in_tree(nil, loc_cs, prefix) do
    loc_cs
    |> Repo.insert(prefix: prefix)
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

  def update_location(%Location{} = location, attrs, prefix, user \\ %{}) do
    existing_parent_id = HierarchyManager.parent_id(location)

    result =
      cond do
        Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
          new_parent_id = attrs["parent_id"]

          loc_cs =
            update_location_default_changeset_pipe(location, attrs)
            |> check_asset_category_type_loc(prefix)

          update_location_in_tree(new_parent_id, loc_cs, location, prefix)

        true ->
          loc_cs =
            update_location_default_changeset_pipe(location, attrs)
            |> check_asset_category_type_loc(prefix)

          Repo.update(loc_cs, prefix: prefix)
      end

    # create_status_track_for_asset(result, location, attrs, "L", user, prefix)

    case result do
      {:ok, updated_location} ->
        update_status_track_for_asset(updated_location, location.status, "L", user, prefix)
        Elixir.Task.start(fn -> push_alert_notification_for_asset(location, updated_location, location.site_id, prefix) end)
        result
      _ ->
        result
    end

  end

  defp update_status_track_for_asset(asset, previous_status, _asset_type, _user, _prefix) when asset.status == previous_status do
    {:ok, asset}
  end

  defp update_status_track_for_asset(asset, _previous_status, asset_type, user, prefix) do
    update_last_status_record(asset, asset_type, prefix)
    user_id =
      case length(Map.keys(user)) do
        0 ->
          nil

        _ ->
          user.id
      end
    create_track_for_asset_status(asset, asset_type, prefix, user_id)
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
    user_id =
      case length(Map.keys(user)) do
        0 ->
          nil

        _ ->
          user.id
      end
    case result do
      {:ok, asset} ->
        if attrs["status"] != asset_before_insertion.status do
          IO.inspect("Inside If")
          asset_status_update_attrs = %{
            "asset_id" => asset.id,
            "asset_type" => asset_type,
            "status_changed" => asset.status,
            "user_id" => user_id,
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

  defp update_location_default_changeset_pipe(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
  end

  def update_active_status_for_location(%Location{} = location, location_params, prefix) do
    case location_params do
      %{"active" => false} ->
        deactivate_children(location, Location, prefix)

      %{"active" => true} ->
        parent_id = HierarchyManager.parent_id(location)
        handle_hierarchical_activation(location, location_params, Location, prefix, parent_id)
    end
  end

  def update_locations(location_changes, prefix) do
    locations_failed_to_update =
      Stream.map(location_changes["ids"], fn id ->
        location = get_location!(id, prefix)
        case update_location(location, Map.drop(location_changes, ["ids"]), prefix) do
          {:ok, _updated_location} -> true
          _ -> id
        end
      end) |> Enum.filter(fn x -> x != true end)

    %{
      success: (if length(locations_failed_to_update) > 0, do: false, else: true),
      falied_location_ids: locations_failed_to_update
    }
  end

  def delete_location(%Location{} = location, prefix) do
    cond do
      has_descendants?(location, prefix) ->
        {
          :could_not_delete,
          "Cannot be deleted as there are descendants to this location"
        }
      has_equipment?(location, prefix) ->
        {
          :could_not_delete,
          "Cannot be deleted as there are equipments associated with this location"
        }
      has_workorder_schedule?(location, prefix) ->
        {
          :could_not_delete,
          "Cannot be deleted as there are workorder schedules associated with this location"
        }
      true ->
        {:ok, updated_location} = update_location(location, %{"active" => false}, prefix)
        Elixir.Task.start(fn -> push_alert_notification_for_asset(updated_location, nil, updated_location.site_id, prefix) end)
        {:deleted, "Location was deleted"}
    end
  end

  # def delete_location(%Location{} = location, prefix) do
  #   subtree = HierarchyManager.subtree(location)
  #   result = Repo.delete_all(subtree, prefix: prefix)
  #   case result do
  #     {_, nil} ->
  #       # push_alert_notification_for_asset(location, nil, "L", location.site_id,prefix)
  #       result

  #     _ ->
  #       result
  #   end
  # end

  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  alias Inconn2Service.AssetConfig.Equipment

  def list_equipments(site_id, prefix) do
    Equipment
    |> Repo.add_active_filter()
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
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

  def list_equipments(site_id, _query_params, prefix) do
    Equipment
    |> Repo.add_active_filter()
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()

  end

  def list_equipments(prefix) do
    Equipment
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
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

  def list_equipments_of_location(location_id, _query_params, prefix) do
    Equipment
    |> Repo.add_active_filter()
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

  def list_equipments_by_location_ids(location_ids, prefix) do
    from(e in Equipment, where: e.location_id in ^location_ids)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_equipments_by_ids(ids, prefix) do
    from(e in Equipment, where: e.id in ^ids)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

  def list_equipments_of_asset_category_and_not_in_given_ids(nil, _ids, _prefix), do: []
  def list_equipments_of_asset_category_and_not_in_given_ids(ac_id, ids, prefix) do
    from(e in Equipment, where: e.asset_category_id == ^ac_id and e.id not in ^ids)
    |> Repo.all(prefix: prefix)
  end

  def list_equipments_of_asset_category_and_in_given_ids(nil, _ids, _prefix), do: []
  def list_equipments_of_asset_category_and_in_given_ids(ac_id, ids, prefix) do
    from(e in Equipment, where: e.asset_category_id == ^ac_id and e.id  in ^ids)
    |> Repo.all(prefix: prefix)
  end

  def list_equipments_not_in_given_ids(ids, prefix) do
    from(e in Equipment, where: e.id not in ^ids)
    |> Repo.all(prefix: prefix)
  end

  def list_equipments_ticket_qr(site_id, prefix) do
    equipment = list_equipments(site_id, prefix)
    Enum.map(equipment, fn e ->
      %{
        id: e.id,
        asset_name: e.name,
        asset_code: e.equipment_code,
        asset_qr_url: "/api/equipments/#{e.id}/ticket_qr_code_png"
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

  def list_locations_ticket_qr(site_id, prefix) do
    locations = list_locations(site_id, prefix)
    Enum.map(locations, fn l ->
      %{
        id: l.id,
        asset_name: l.name,
        asset_code: l.location_code,
        asset_qr_url: "/api/locations/#{l.id}/ticket_qr_code_png"
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

  def get_equipment!(id, prefix), do: Repo.get!(Equipment, id, prefix: prefix)
  def get_equipment(id, prefix), do: Repo.get(Equipment, id, prefix: prefix)

  def get_equipment_qr_code(id, prefix) do
    equipment = get_equipment(id, prefix)
    {EQRCode.encode("E:" <> equipment.qr_code) |> EQRCode.png, equipment}
  end

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} ->
      "#{key}: #{value}"
    end)
    |> Enum.join(";")
  end

  def get_equipment_qr_as_pdf(id, prefix) do
    "inc_" <> sub_domain = prefix
    equipment = get_equipment!(id, prefix)
    parent_string = Enum.map(equipment.path, fn id ->  get_equipment(id, prefix).name end) |> Enum.join("/")
    parent_string_with_slash =
      case String.length(parent_string) do
        0 -> ""
        _ -> parent_string <> "/"
      end
    string =
      Sneeze.render(
        [
          :center,
          [
            :img,
            %{
              src: "http://#{sub_domain}.localhost:4000/api/equipments/#{id}/qr_code",
              style: style(%{
                "margin-top" => "150px",
                "height" => "800px",
                "width" => "800px"
              })
            }
          ],
          [:h3, %{style: style(%{"width" => "90%", "font-size" => "20px"})}, "#{parent_string_with_slash}#{equipment.name}"],
          [:h3, %{style: style(%{"width" => "90%", "font-size" => "20px"})}, "#{equipment.equipment_code}"],
          [
            :span,
            %{"style" => style(%{"float" => "right", "margin-top" => "100px"})},
            "Powered By InConn"
          ]
        ]
      )
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    {equipment.name, pdf_content}
  end

  def get_location_qr_as_pdf(id, prefix) do
    "inc_" <> sub_domain = prefix
    location = get_location!(id, prefix)
    parent_string = Enum.map(location.path, fn id ->  get_location(id, prefix).name end) |> Enum.join("/")
    parent_string_with_slash =
      case String.length(parent_string) do
        0 -> ""
        _ -> parent_string <> "/"
      end
    string =
      Sneeze.render(
        [
          :center,
          [
            :img,
            %{
              src: "http://#{sub_domain}.localhost:4000/api/locations/#{id}/qr_code",
              style: style(%{
                "margin-top" => "150px",
                "height" => "800px",
                "width" => "800px"
              })
            }
          ],
          [:h3, %{style: style(%{"width" => "90%", "font-size" => "20px"})}, "#{parent_string_with_slash}#{location.name}"],
          [:h3, %{style: style(%{"width" => "90%", "font-size" => "20px"})}, "#{location.location_code}"],
          [
            :span,
            %{"style" => style(%{"float" => "right", "margin-top" => "100px"})},
            "Powered By InConn"
          ]
        ]
      )
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    {location.name, pdf_content}
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

  def create_equipment(attrs \\ %{}, prefix) do
    parent_id = Map.get(attrs, "parent_id", nil)

    eq_cs =
      %Equipment{}
      |> Equipment.changeset(attrs)
      |> check_asset_category_type_eq(prefix)
      |> check_site_id_of_location(prefix)
      |> validate_custom_field_type(prefix, "equipment")

    result = create_equipment_in_tree(parent_id, eq_cs, prefix)

    case result do
      {:ok, equipment} ->
        create_track_for_asset_status(equipment, "E", prefix)
        Elixir.Task.start(fn -> push_alert_notification_for_asset(nil, equipment, equipment.site_id, prefix) end)
        result
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
      case Repo.get(AssetCategory, ac_id, prefix: prefix) do
        nil ->
          add_error(eq_cs, :asset_category_id, "Asset category ID is invalid")

        asset_category ->
          case asset_category.asset_type != "E" do
            true ->
              add_error(eq_cs, :asset_category_id, "Asset category should be equipment")

            false ->
              eq_cs
          end
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

  def update_equipment(%Equipment{} = equipment, attrs, prefix, user \\ %{}) do
    existing_parent_id = HierarchyManager.parent_id(equipment)

    result =
      cond do
        Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
          new_parent_id = attrs["parent_id"]

          eq_cs =
            update_equipment_default_changeset_pipe(equipment, attrs)
            |> check_asset_category_type_eq(prefix)
            |> check_site_id_of_location(prefix)
            |> validate_custom_field_type(prefix, "equipment")

          update_equipment_in_tree(new_parent_id, eq_cs, equipment, prefix)

        true ->
          eq_cs =
            update_equipment_default_changeset_pipe(equipment, attrs)
            |> check_asset_category_type_eq(prefix)
            |> check_site_id_of_location(prefix)
            |> validate_custom_field_type(prefix, "equipment")


          Repo.update(eq_cs, prefix: prefix)
      end

    case result do
      {:ok, updated_equipment} ->
        update_status_track_for_asset(updated_equipment, equipment.status, "E", user, prefix)
        Elixir.Task.start(fn -> push_alert_notification_for_asset(equipment, updated_equipment, equipment.site_id, prefix) end)
        result
      _ ->
        result
    end

    create_status_track_for_asset(result, equipment, attrs, "E", user, prefix)
  end

  def update_active_status_for_equipment(%Equipment{} = equipment, equipment_params, prefix) do
    case equipment_params do
      %{"active" => false} ->
        deactivate_children(equipment, Equipment, prefix)
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

  def update_equipments(equipment_changes, prefix) do
    equipments_failed_to_update =
      Stream.map(equipment_changes["ids"],  fn id ->
        equipment = get_equipment!(id, prefix)
        case update_equipment(equipment, Map.drop(equipment_changes, ["ids"]), prefix) do
          {:ok, _updated_equipment} -> true
          _ -> id
        end
      end) |> Enum.filter(fn x -> x != true end)
    %{
      success: (if length(equipments_failed_to_update) > 0, do: false, else: true),
      failed_equipment_ids: equipments_failed_to_update
    }
  end

  defp update_equipment_default_changeset_pipe(%Equipment{} = equipment, attrs) do
    equipment
    |> Equipment.changeset(update_custom_fields(equipment, attrs))
  end

  def delete_equipment(%Equipment{} = equipment, prefix) do
    cond do
      has_descendants?(equipment, prefix) ->
        {
          :could_not_delete,
          "Cannot be deleted as there are descendants associated with this equipment"
        }

      has_workorder_schedule?(equipment, prefix) ->
        {
         :could_not_delete,
         "Cannot be deleted as there are workorder schedule associated with this equipment"
        }
      true ->
        {:ok, updated_equipment} = update_equipment(equipment, %{"active" => false}, prefix)
        Elixir.Task.start(fn -> push_alert_notification_for_asset(updated_equipment, nil, updated_equipment.site_id, prefix) end)
        {:deleted, "Equipment was deleted"}
    end
  end


  # def delete_equipment(%Equipment{} = equipment, prefix) do
  #   subtree = HierarchyManager.subtree(equipment)
  #   result = Repo.delete_all(subtree, prefix: prefix)
  #   case result do
  #     {_, nil} ->
  #       push_alert_notification_for_asset(equipment, nil, "E", prefix)
  #       result

  #     _ ->
  #       result
  #   end
  # end

  def get_asset_by_type(asset_id, asset_type, prefix) do
    case asset_type do
      "L" ->
        get_location(asset_id, prefix)

      "E" ->
        get_equipment(asset_id, prefix)
    end
  end

  #list assets by parent_id for both location and equipment
  def get_assets_by_parent_id(parent_id, prefix) do
    asset_category = get_asset_category!(parent_id, prefix)
    case asset_category.asset_type do
      "L" ->
         Location |> where([parent_id: ^parent_id]) |> Repo.all(prefix: prefix)

      "E" ->
        Equipment |> where([parent_id: ^parent_id]) |> Repo.all(prefix: prefix)
    end
  end

  def change_equipment(%Equipment{} = equipment, attrs \\ %{}) do
    Equipment.changeset(equipment, attrs)
  end

  #remove asset
  # def push_alert_notification_for_remove_asset(existing_asset, updated_asset, site_id, prefix) do
  #   escalation_user_maps = Staff.form_user_maps_by_user_ids([updated_asset.asset_manager_id], prefix)
  #   asset_type = get_asset_code_from_asset_struct(updated_asset)
  #   # exist_asset_name = get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
  #   exist_asset_name =
  #   if existing_asset.parent_id == nil do
  #     "root"
  #   else
  #     get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
  #   end

  #   generate_alert_notification("REAST", site_id, ["#{existing_asset.name} removed from #{exist_asset_name}"], [existing_asset.name, existing_asset.parent_id], [], escalation_user_maps, prefix)
  # end

  # #add new asset
  # def push_alert_notification_for_asset(existing_asset, updated_asset, site_id, prefix) do
  #   user_maps =
  #         %{"site_id" => updated_asset.site_id, "asset_category_id" => updated_asset.asset_category_id}
  #         |> list_users_from_scope(prefix)
  #         |> Staff.form_user_maps_by_user_ids(prefix)

  #   asset_type = get_asset_code_from_asset_struct(updated_asset)
  #   # exist_asset_name = get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
  #   exist_asset_name =
  #   if existing_asset.parent_id == nil do
  #     "root"
  #   else
  #     get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
  #   end

  #   generate_alert_notification("ADNAS", site_id, ["#{updated_asset.name} added at #{exist_asset_name}"],[], user_maps, [], prefix)
  #   {:ok, updated_asset}
  # end

  def push_alert_notification_for_asset(existing_asset, updated_asset, site_id, prefix) do
    date_time = get_site_date_time_now(site_id, prefix)

    #asset edit
    generate_alert_notification("EDASD", site_id, [updated_asset.name], [], [], [], prefix)

    cond do
      #asset status to breakdown
      existing_asset.status != updated_asset.status && updated_asset.status == "BRK" ->
        escalation_user_maps = Staff.form_user_maps_by_user_ids([updated_asset.asset_manager_id], prefix)

        user_maps =
          %{"site_id" => updated_asset.site_id, "asset_category_id" => updated_asset.asset_category_id}
          |> list_users_from_scope(prefix)
          |> Staff.form_user_maps_by_user_ids(prefix)

        generate_alert_notification("ASTCB", site_id, [updated_asset.name, date_time], [updated_asset.name, date_time], user_maps, escalation_user_maps, prefix)

      #new asset
      user_maps =
       %{"site_id" => updated_asset.site_id, "asset_category_id" => updated_asset.asset_category_id}
       |> list_users_from_scope(prefix)
       |> Staff.form_user_maps_by_user_ids(prefix)

       asset_type = get_asset_code_from_asset_struct(updated_asset)
       # exist_asset_name = get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
       exist_asset_name =
       if existing_asset.parent_id == nil do
         "root"
       else
         get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
       end

      generate_alert_notification("ADNAS", site_id, [updated_asset.name, exist_asset_name],[], user_maps, [], prefix)

      #remove asset
      escalation_user_maps = Staff.form_user_maps_by_user_ids([updated_asset.asset_manager_id], prefix)
      asset_type = get_asset_code_from_asset_struct(updated_asset)
      # exist_asset_name = get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
      exist_asset_name =
      if existing_asset.parent_id == nil do
        "root"
      else
        get_asset_by_type(existing_asset.parent_id, asset_type, prefix).name
      end

      generate_alert_notification("REAST", site_id, [existing_asset.name, exist_asset_name], [existing_asset.name, existing_asset.parent_id], [], escalation_user_maps, prefix)

      #asset status to on/off
      existing_asset.status != updated_asset.status && updated_asset.status in ["ON", "OFF"]  ->

        user_maps =
        %{"site_id" => updated_asset.site_id, "asset_category_id" => updated_asset.asset_category_id}
        |> list_users_from_scope(prefix)
        |> Staff.form_user_maps_by_user_ids(prefix)

        generate_alert_notification("ASTCO", site_id, [updated_asset.name, updated_asset.status, date_time], user_maps, [], [], prefix)

      #asset status to transit
      existing_asset.status != updated_asset.status && updated_asset.status == "TRN"  ->
        user_maps = Staff.form_user_maps_by_user_ids([updated_asset.asset_manager_id], prefix)
        generate_alert_notification("ASTCT", site_id, [updated_asset.name, date_time], [], user_maps, [], prefix)

      #modify asset tree hierarchy
      existing_asset.parent_id != updated_asset.parent_id ->
        # description = ~s(#{updated_asset.name}'s hierarchy has been changed)
        # create_asset_alert_notification("ASMH", description, updated_asset, asset_type, updated_asset.site_id, false, prefix)
        user_maps =
        %{"site_id" => updated_asset.site_id, "asset_category_id" => updated_asset.asset_category_id}
        |> list_users_from_scope(prefix)
        |> Staff.form_user_maps_by_user_ids(prefix)

        generate_alert_notification("MASTH", site_id, ["asset tree hierarchy of #{existing_asset.name} are modified"], [], user_maps, [], prefix)

      true ->
        {:ok, updated_asset}
    end

    {:ok, updated_asset}
  end

  # defp create_asset_alert_notification(alert_code, description, nil, asset_type, site_id, email_required, prefix) do
  #   alert = Common.get_alert_by_code(alert_code)
  #   alert_config = Prompt.get_alert_notification_config_by_alert_id_and_site_id(alert.id, site_id, prefix)
  #   alert_identifier_date_time = NaiveDateTime.utc_now()
  #   case alert_config do
  #     nil ->
  #       {:not_found, "Alert Not Configured"}

  #     _ ->
  #       attrs = %{
  #         "alert_notification_id" => alert.id,
  #         "asset_id" => nil,
  #         "asset_type" => asset_type,
  #         "type" => alert.type,
  #         "site_id" => site_id,
  #         "alert_identifier_date_time" => alert_identifier_date_time,
  #         "description" => description
  #       }

  #       Enum.map(alert_config.addressed_to_user_ids, fn id ->
  #         Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
  #         if email_required do
  #           user = Inconn2Service.Staff.get_user!(id, prefix)
  #           Inconn2Service.Email.send_alert_email(user, description)
  #         end
  #       end)

  #      if alert.type == "al" and alert_config.is_escalation_required do
  #       Common.create_alert_notification_scheduler(%{
  #         "alert_code" => alert.code,
  #         "alert_identifier_date_time" => alert_identifier_date_time,
  #         "escalation_at_date_time" => NaiveDateTime.add(alert_identifier_date_time, alert_config.escalation_time_in_minutes * 60),
  #         "escalated_to_user_ids" => alert_config.escalated_to_user_ids,
  #         "site_id" => site_id,
  #         "prefix" => prefix
  #       })
  #      end
  #   end
  # end

  # defp create_asset_alert_notification(alert_code, description, updated_asset, asset_type, site_id, _email_required, prefix) do
  #   alert = Common.get_alert_by_code(alert_code)
  #   IO.inspect(alert)
  #   alert_config = Prompt.get_alert_notification_config_by_alert_id_and_site_id(alert.id, updated_asset.site_id, prefix)
  #   alert_identifier_date_time = NaiveDateTime.utc_now()
  #   case alert_config do
  #     nil ->
  #       {:ok, updated_asset}

  #     _ ->
  #       attrs = %{
  #         "alert_notification_id" => alert.id,
  #         "asset_id" => updated_asset.id,
  #         "asset_type" => asset_type,
  #         "type" => alert.type,
  #         "alert_identifier_date_time" => alert_identifier_date_time,
  #         "description" => description,
  #         "site_id" => site_id
  #       }

  #       Enum.map(alert_config.addressed_to_user_ids, fn id ->
  #         Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
  #       end)

  #       if alert.type == "al" and alert_config.is_escalation_required do
  #         Common.create_alert_notification_scheduler(%{
  #           "alert_code" => alert.code,
  #           "alert_identifier_date_time" => alert_identifier_date_time,
  #           "escalated_to_user_ids" => alert_config.escalated_to_user_ids,
  #           "site_id" => site_id,
  #           "escalation_at_date_time" => NaiveDateTime.add(alert_identifier_date_time, alert_config.escalation_time_in_minutes * 60),
  #           "prefix" => prefix
  #         })
  #       end
  #   end
  # end


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

  def list_parties(query_params, prefix) do
    party_query(Party, query_params)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_SP(prefix) do
    query =
      from(p in Party,
        where:
          p.party_type ==
            "SP"
      )

    Repo.all(query, prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_AO(prefix) do
    query =
      from(p in Party,
        where:
          p.allowed_party_type ==
            "AO"
      )

    Repo.all(query, prefix: prefix)
    |> Repo.sort_by_id()
  end

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

  def update_party(%Party{} = party, attrs, prefix) do
    party
    |> Party.changeset(attrs)
    |> validate_party(attrs, prefix)
    |> Repo.update(prefix: prefix)
  end

  # def (%Party{} = party, prefix) do
  #   Repo.delete(party, prefix: prefix)
  # end

  def delete_party(%Party{} = party, prefix) do
    cond do
      has_contract?(party, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Contracts associated with it"
        }

      has_site?(party, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Sites associated with it"
        }

      has_org_unit?(party, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are Org unit associated with it"
        }

      has_employee?(party, prefix) ->
       {:could_not_delete,
          "Cannot be deleted as there are Employee associated with it"
       }

      has_user?(party, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are User associated with it"
        }

     true ->
       update_party(party, %{"active" => false}, prefix)
        {:deleted,
          "The party was disabled"
        }
    end
  end

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

  def list_asset_status_tracks(prefix) do
    Repo.all(AssetStatusTrack, prefix: prefix)
  end

  def get_asset_status_track!(id, prefix), do: Repo.get!(AssetStatusTrack, id, prefix: prefix)

  def create_asset_status_track(attrs \\ %{}, prefix) do
    %AssetStatusTrack{}
    |> AssetStatusTrack.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_asset_status_track(%AssetStatusTrack{} = asset_status_track, attrs, prefix) do
    asset_status_track
    |> AssetStatusTrack.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_asset_status_track(%AssetStatusTrack{} = asset_status_track, prefix) do
    Repo.delete(asset_status_track, prefix: prefix)
  end

  def change_asset_status_track(%AssetStatusTrack{} = asset_status_track, attrs \\ %{}) do
    AssetStatusTrack.changeset(asset_status_track, attrs)
  end

  alias Inconn2Service.AssetConfig.SiteConfig

  def list_site_config(prefix) do
    Repo.all(SiteConfig, prefix: prefix)
  end

  def get_site_config!(id, prefix), do: Repo.get!(SiteConfig, id, prefix: prefix)

  def get_site_config_by_site_id(site_id, prefix) do
    from(sc in SiteConfig, where: sc.site_id == ^site_id)
    |> Repo.all(prefix: prefix)
  end

  def get_site_config_by_site_id_and_type(site_id, type, prefix) do
    from(sc in SiteConfig, where: sc.site_id == ^site_id and sc.type == ^type)
    |> Repo.one(prefix: prefix)
  end

  def create_site_config(attrs \\ %{}, prefix) do
    %SiteConfig{}
    |> SiteConfig.changeset(attrs)
    |> validate_type_one_time(prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp validate_type_one_time(cs, prefix) do
    site_id = get_field(cs, :site_id)
    type = get_field(cs, :type)
    if site_id != nil and type != nil do
      case get_site_config_by_site_id_and_type(site_id, type, prefix) do
        nil ->
            cs
        _ ->
            add_error(cs, :type, "already exists for this site")
      end
    else
      cs
    end
  end

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

  def delete_site_config(%SiteConfig{} = site_config, prefix) do
    Repo.delete(site_config, prefix: prefix)
  end


  def change_site_config(%SiteConfig{} = site_config, attrs \\ %{}) do
    SiteConfig.changeset(site_config, attrs)
  end


  def get_assets_with_offset(asset_type, site_id,query_params, prefix) do
    page_no = if is_nil(query_params["page_no"]), do: 1, else: String.to_integer(query_params["page_no"]) - 1
    per_page = String.to_integer(query_params["per_page"])
    {assets_query, total_query} =
      case asset_type do
        "E" ->
          get_equipments_with_offset_query(per_page, page_no * per_page, query_params, site_id)

        "L" ->
          get_locations_with_offset_query(per_page, page_no * per_page, query_params, site_id)
      end

    sorted_assets_query =
      cond do
        !is_nil(query_params["column"]) && !is_nil(query_params["sort"]) ->
          get_dynamic_query_for_offset_assets(assets_query, query_params["column"], query_params["sort"])

        !is_nil(query_params["column"]) ->
          get_dynamic_query_for_offset_assets(assets_query, query_params["column"])

        true ->
          assets_query
      end

    %{
        page_no: page_no,
        assets: Repo.all(sorted_assets_query, prefix: prefix) |> Enum.map(fn asset -> preload_parent(asset, asset_type, prefix) end),
        last_page: (if Repo.one(total_query, prefix: prefix) - page_no * per_page < per_page, do: true, else: false)
    }
  end

  def preload_parent(asset, asset_type, prefix) do
    cond do
      length(asset.path) != 0 && asset_type == "E" ->
        Map.put(asset, :parent, get_equipment(List.last(asset.path), prefix))


      length(asset.path) != 0 && asset_type == "L" ->
        Map.put(asset, :parent, get_location(List.last(asset.path), prefix))

      true ->
        Map.put(asset, :parent, nil)
    end
  end

  def get_equipments_with_offset_query(per_page, offset, _query_params, site_id) do
    common_query = common_query_for_equipments(site_id)
    {
      from(q  in common_query, limit: ^per_page, offset: ^offset),
      from(q in common_query, select: count(q.id))
    }
  end

  def common_query_for_equipments(site_id) do
    from(e in Equipment, where: e.site_id == ^site_id)
  end

  def common_query_for_locations(site_id) do
    from(l in Location, where: l.site_id == ^site_id)
  end


  def get_dynamic_query_for_offset_assets(query, column_name, sort \\ "asc") do
    order_by_list = [{:"#{sort}", :"#{column_name}"}]
    from(q in query, order_by: ^order_by_list)
  end

  def get_locations_with_offset_query(per_page, offset, _query_params, site_id) do
    common_query = common_query_for_locations(site_id)
    {
      from(from q in common_query, limit: ^per_page, offset: ^offset),
      from(q in common_query, select: count(q.id))
    }
  end

  def list_users_from_scope(query_params, prefix) do
    query = from(s in Scope, where: s.active == true)

    scope_query =
      Enum.reduce(query_params, query, fn
        {"site_id", site_id}, acc ->
          from q in acc,
          where: ^site_id == q.site_id
        {"location_id", location_id}, acc ->
          from q in acc,
          where: ^location_id in q.location_ids
        {"asset_category_id", asset_category_id}, acc ->
          from q in acc,
          where: ^asset_category_id in q.asset_category_ids
        _, query ->
          query
      end)

      party_ids =
      from(s in scope_query,
      join: c in Contract, on: s.contract_id == c.id, where: c.active == true,
      join: p in Party, on: c.party_id == p.id, where: p.active == true,
      select: p.id)
      |> Repo.all(prefix: prefix)

    from(u in User, where: u.party_id in ^party_ids and u.active == true, select: u.id) |> Repo.all(prefix: prefix)
  end

  defp validate_custom_field_type(cs, prefix, entity) do
    custom_field_values = get_field(cs, :custom, nil)
    custom_fields_entry = Inconn2Service.Custom.get_custom_fields_by_entity(entity, prefix)
    cond do
      !is_nil(custom_field_values) && !is_nil(custom_fields_entry) ->
        boolean_array =
          Stream.map(get_and_filter_required_type(custom_field_values, entity, prefix), fn e ->
            if check_type(custom_field_values[e.field_name], e.field_type) do true else {e.field_name, e.field_type} end
          end) |> Enum.filter(fn e -> e  != true end)

        case length(boolean_array) do
          0 -> cs
          _ ->
            errors =
              Enum.map(boolean_array, fn {field_name, field_type} -> "Expected #{field_type} value for #{field_name}"  end)
              |> Enum.join(",")
            add_error(cs, :custom, errors)
        end
      !is_nil(custom_field_values) ->
        add_error(cs, :custom, "Custom fields not configured")
      true -> cs
    end
  end

  defp create_zone_in_tree(nil, zone_cs, prefix) do
    Repo.insert(zone_cs, prefix: prefix)
  end

  defp create_zone_in_tree(parent_id, zone_cs, prefix) do
    case Repo.get(Zone, parent_id, prefix: prefix) do
      nil ->
        add_error(zone_cs, :parent_id, "Parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        zone_cs
        |> HierarchyManager.make_child_of(parent)
        |> Repo.insert(prefix: prefix)
    end
  end

  defp update_zone_in_tree(nil, zone_cs, zone, prefix) do
    descendents = HierarchyManager.descendants(zone) |> Repo.all(prefix: prefix)
    # adjust the path (from old path to ne path )for all descendents
    zone_cs = change(zone_cs, %{path: []})
    make_zone_changeset_and_update(zone_cs, zone, descendents, [], prefix)
  end

  defp update_zone_in_tree(new_parent_id, zone_cs, zone, prefix) do
    # Get the new parent and check
    case Repo.get(Zone, new_parent_id, prefix: prefix) do
      nil ->
        add_error(zone_cs, :parent_id, "New parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        # Get the descendents
        descendents = HierarchyManager.descendants(zone) |> Repo.all(prefix: prefix)
        new_path = parent.path ++ [parent.id]
        # make this node child of new parent
        head_cs = HierarchyManager.make_child_of(zone_cs, parent)
        make_zone_changeset_and_update(head_cs, zone, descendents, new_path, prefix)
    end
  end

  defp make_zone_changeset_and_update(head_cs, zone, descendents, new_path, prefix) do
    # adjust the path (from old path to ne path )for all descendents
    multi =
      [
        {zone.id, head_cs}
        | Enum.map(descendents, fn d ->
            {_, rest} = Enum.split_while(d.path, fn e -> e != zone.id end)
            {d.id, Zone.changeset(d, %{}) |> change(%{path: new_path ++ rest})}
          end)
      ]
      |> Enum.reduce(Multi.new(), fn {indx, cs}, multi ->
        Multi.update(multi, :"zone#{indx}", cs, prefix: prefix)
      end)

    case Repo.transaction(multi, prefix: prefix) do
      {:ok, zn} -> {:ok, Map.get(zn, :"zone#{zone.id}")}
      _ -> {:error, head_cs}
    end
  end

  defp get_and_filter_required_type(custom_field_values, entity, prefix) do
    entity_record = custom_field_for_entity_query(entity) |> Repo.one(prefix: prefix)
    Stream.filter(entity_record.fields, fn field ->  field.field_name in Map.keys(custom_field_values) end)
  end


  defp deactivate_children(resource, module, prefix) do
    descendants = HierarchyManager.descendants(resource)
    Repo.update_all(descendants, [set: [active: false]], prefix: prefix)
    resource |> module.changeset(%{"active" => false}) |> Repo.update(prefix: prefix)
  end

  defp custom_field_for_entity_query(entity), do: from cf in CustomFields, where: cf.entity == ^entity

  defp check_type(value, "integer"), do: is_integer(value)
  defp check_type(value, "float"), do: is_float(value)
  defp check_type(value, "string"), do: is_binary(value)
  defp check_type(value, "text"), do: is_binary(value)
  defp check_type(value, "date"), do: is_date?(value)
  defp check_type(value, "list_of_values"), do: is_list(value)


  defp sort_sites(sites), do: Enum.sort_by(sites, &(&1.name))
  defp sort_locations(locations), do: Enum.sort_by(locations, &(&1.updated_at), {:desc, NaiveDateTime})
end

defmodule Inconn2Service.InventoryManagement do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.{AssetConfig, Staff}
  alias Inconn2Service.InventoryManagement.{InventorySupplier, InventoryItem}
  alias Inconn2Service.InventoryManagement.{UomCategory, UnitOfMeasurement, Store}

  def list_uom_categories(prefix) do
    from(uc in UomCategory, where: uc.active)
    |> Repo.all(prefix: prefix)
  end

  def get_uom_category!(id, prefix), do: Repo.get!(UomCategory, id, prefix: prefix)

  def create_uom_category(attrs \\ %{}, prefix) do
    %UomCategory{}
    |> UomCategory.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_uom_category(%UomCategory{} = uom_category, attrs, prefix) do
    uom_category
    |> UomCategory.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  # Function commented because soft delete was implemented with the same
  # def delete_uom_category(%UomCategory{} = uom_category, prefix) do
  #   Repo.delete(uom_category, prefix: prefix)
  # end

  def delete_uom_category(%UomCategory{} = uom_category, prefix) do
    cond do
      has_unit_of_measurements?(uom_category, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the UOM category has UOMs associated with it"
        }

      true ->
        update_uom_category(uom_category, %{"active" => false}, prefix)
        {:deleted,
        "The UOM category was disabled, you will be able to see transactions associated with the UOM"
        }
    end
  end

  def change_uom_category(%UomCategory{} = uom_category, attrs \\ %{}) do
    UomCategory.changeset(uom_category, attrs)
  end

  #Context functions for %UnitOfMeasurement{}
  def list_unit_of_measurements(%{"uom_category_id" => uom_category_id}, prefix) when not is_nil(uom_category_id) do
    from(uom in UnitOfMeasurement, where: uom.uom_category_id == ^uom_category_id and uom.active)
    |> Repo.all(prefix: prefix) |> Repo.preload(:uom_category)
  end

  def list_unit_of_measurements(_query_params, prefix) do
    from(uom in UnitOfMeasurement, where: uom.active)
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:uom_category)
  end

  def list_unit_of_measurements_by_uom_category(uom_category_id, prefix) do
    from(uom in UnitOfMeasurement, where: uom.uom_category_id == ^uom_category_id and uom.active)
    |> Repo.all(prefix: prefix) |> Repo.preload(:uom_category)
  end

  def get_unit_of_measurement!(id, prefix), do: Repo.get!(UnitOfMeasurement, id, prefix: prefix) |> Repo.preload(:uom_category)

  def create_unit_of_measurement(attrs \\ %{}, prefix) do
    %UnitOfMeasurement{}
    |> UnitOfMeasurement.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_uom_category()
  end

  def update_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, attrs, prefix) do
    unit_of_measurement
    |> UnitOfMeasurement.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_uom_category()
  end

  # Function commented because soft delete was implemented with the same
  # def delete_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, prefix) do
  #   Repo.delete(unit_of_measurement, prefix: prefix)
  # end

  def delete_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, prefix) do
    cond do
      has_items?(unit_of_measurement, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the UOM has items associated with it"
        }

      has_transaction?(unit_of_measurement, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the UOM has transaction associated with it"
        }

      true ->
        update_unit_of_measurement(unit_of_measurement, %{"active" => false}, prefix)
        {:deleted,
        "The UOM was disabled, you will be able to see transactions associated with the UOM"
        }
    end
  end

  def change_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, attrs \\ %{}) do
    UnitOfMeasurement.changeset(unit_of_measurement, attrs)
  end

  # Context functions for %Store{}
  def list_stores(query_params, prefix) do
    query = from s in Store, where: s.active
    query = Enum.reduce(query_params, query, fn
      {"type", type}, query ->
        from q in query, where: q.person_or_location_based == ^type

      {"site_id", site_id}, query ->
        from q in query, where: q.site_id == ^site_id

      {"location_id", location_id}, query ->
        from q in query, where: q.location_id == ^location_id

      {"user_id", user_id}, query ->
        from q in query, where: q.user_id == ^user_id

      _ , query ->
        query
    end)
    Repo.all(query, prefix: prefix)
      |> Stream.map(fn store -> preload_user_for_store(store, prefix) end)
      |> Enum.map(fn store -> preload_site_and_location_for_store(store, prefix) end)
  end

  def list_stores_by_site(site_id, prefix) do
    from(s in Store, where: s.site_id == ^site_id and s.active)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn store -> preload_user_for_store(store, prefix) end)
    |> Enum.map(fn store -> preload_site_and_location_for_store(store, prefix) end)
  end

  def list_stores_by_location(location_id, prefix) do
    from(s in Store, where: s.location_id == ^location_id and s.active)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn store -> preload_user_for_store(store, prefix) end)
    |> Enum.map(fn store -> preload_site_and_location_for_store(store, prefix) end)
  end

  def get_store!(id, prefix) do
    Repo.get!(Store, id, prefix: prefix)
    |> preload_site_and_location_for_store(prefix)
    |> preload_user_for_store(prefix)
  end

  def create_store(attrs \\ %{}, prefix) do
      %Store{}
      |> Store.changeset(read_attachment(attrs))
      |> Repo.insert(prefix: prefix)
      |> preload_site_and_location_for_store(prefix)
      |> preload_user_for_store(prefix)
  end

  def update_store(%Store{} = store, attrs, prefix) do
    store
    |> Store.update_changeset(read_attachment(attrs))
    |> Repo.update(prefix: prefix)
    |> preload_site_and_location_for_store(prefix)
    |> preload_user_for_store(prefix)
  end

  # Function commented because soft delete was implemented with the same
  # def delete_store(%Store{} = store, prefix) do
  #   Repo.delete(store, prefix: prefix)
  # end

  def delete_store(%Store{} = store, prefix) do
    cond do
      has_stock?(store, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the store has stock associated with it"
        }

      has_transaction?(store, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the store has transaction associated with it"
        }

      true ->
        update_store(store, %{"active" => false}, prefix)
        {:deleted, nil}
    end
  end

  def change_store(%Store{} = store, attrs \\ %{}) do
    Store.changeset(store, attrs)
  end

  #Context functions for %InventorySupplier{}
  def list_inventory_suppliers(prefix) do
    from(is in InventorySupplier, where: is.active)
    |> Repo.all(prefix: prefix)
  end

  def get_inventory_supplier!(id, prefix), do: Repo.get!(InventorySupplier, id, prefix: prefix)

  def create_inventory_supplier(attrs \\ %{}, prefix) do
    %InventorySupplier{}
    |> InventorySupplier.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_inventory_supplier(%InventorySupplier{} = inventory_supplier, attrs, prefix) do
    inventory_supplier
    |> InventorySupplier.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  # Function commented because soft delete was implemented with the same
  # def delete_inventory_supplier(%InventorySupplier{} = inventory_supplier, prefix) do
  #   Repo.delete(inventory_supplier, prefix: prefix)
  # end

  def delete_inventory_supplier(%InventorySupplier{} = inventory_supplier, prefix) do
    cond do
      has_transaction?(inventory_supplier, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the supplier has transaction associated with it"
        }

      true ->
        update_inventory_supplier(inventory_supplier, %{"active" => false}, prefix)
        {:deleted, nil}
    end
  end

  def change_inventory_supplier(%InventorySupplier{} = inventory_supplier, attrs \\ %{}) do
    InventorySupplier.changeset(inventory_supplier, attrs)
  end

  #Context functions for %InventoryItem{}
  def list_inventory_items(prefix) do
    from(ii in InventoryItem, where: ii.active)
    |> Repo.all(prefix: prefix)
  end

  def get_inventory_item!(id, prefix), do: Repo.get!(InventoryItem, id, prefix: prefix)

  def create_inventory_item(attrs \\ %{}, prefix) do
    %InventoryItem{}
    |> InventoryItem.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_inventory_item(%InventoryItem{} = inventory_item, attrs, prefix) do
    inventory_item
    |> InventoryItem.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  # Function commented because soft delete was implemented with the same
  # def delete_inventory_item(%InventoryItem{} = inventory_item, prefix) do
  #   Repo.delete(inventory_item, prefix: prefix)
  # end

  def delete_inventory_item(%InventoryItem{} = inventory_item, prefix) do
    cond do
      has_stock?(inventory_item, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the item has stock associated with it"
        }

      has_transaction?(inventory_item, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the item has transaction associated with it"
        }

      true ->
        update_inventory_item(inventory_item, %{"active" => false}, prefix)
        {:deleted, nil}
    end
  end

  def change_inventory_item(%InventoryItem{} = inventory_item, attrs \\ %{}) do
    InventoryItem.changeset(inventory_item, attrs)
  end

  #All private functions related to the context
  defp read_attachment(attrs) do
    attachment = Map.get(attrs, "store_image")
    if attachment != nil and attachment != "" do
      IO.inspect(attachment)
      {:ok, attachment_binary} = File.read(attachment.path)
      # attachment_type = attachment.content_type
      attrs
      |> Map.put("store_image", attachment_binary)
      |> Map.put("store_image_type", attachment.content_type)
      |> Map.put("store_image_name", attachment.filename)
    else
      attrs
    end
  end

  defp preload_user_for_store({:error, reason}, _prefix), do: {:error, reason}
  defp preload_user_for_store({:ok, store}, prefix), do: {:ok, preload_user_for_store(store, prefix)}
  defp preload_user_for_store(store, _prefix) when is_nil(store.user_id), do: Map.put(store, :user, nil)
  defp preload_user_for_store(store, prefix), do: Map.put(store, :user, Staff.get_user_without_org_unit(store.user_id, prefix))

  defp preload_site_and_location_for_store({:error, reason}, _prefix), do: {:error, reason}
  defp preload_site_and_location_for_store({:ok, store}, prefix), do: {:ok, preload_site_and_location_for_store(store, prefix)}
  defp preload_site_and_location_for_store(store, _prefix) when is_nil(store.site_id) or is_nil(store.location_id), do:  Map.put(store, :location, nil) |> Map.put(:site, nil)
  defp preload_site_and_location_for_store(store, prefix), do: Map.put(store, :location, AssetConfig.get_location(store.location_id, prefix)) |> Map.put(:site, AssetConfig.get_site(store.site_id, prefix))


  defp preload_uom_category({:ok, unit_of_measurement}), do: {:ok, unit_of_measurement |> Repo.preload(:uom_category)}
  defp preload_uom_category(result), do: result

  defp has_unit_of_measurements?(uom_category, prefix) do
    query = from(uom in UnitOfMeasurement,
        where: uom.uom_category_id == ^uom_category.id and
               uom.active
    )
    case length(Repo.all(query, prefix: prefix)) do
      0 -> false
      _ -> true
    end
  end

  defp has_items?(unit_of_measurement, prefix) do
    item_query = from(i in InventoryItem,
      where:
            (i.consume_unit_of_measurement_id == ^unit_of_measurement.id or
             i.inventory_unit_of_measurement_id == ^unit_of_measurement.id or
             i.purchase_unit_of_measurement_id == ^unit_of_measurement.id) and
             i.active == true
             )
    case length(Repo.all(item_query, prefix: prefix)) do
      0 -> false
      _ -> true
    end
  end

  defp has_stock?(_unit_of_measurement, _prefix) do
    false
  end

  defp has_transaction?(_unit_of_measurement, _prefix) do
    false
  end
end

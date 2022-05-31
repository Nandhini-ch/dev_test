defmodule Inconn2Service.InventoryManagement do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.{AssetConfig, Staff}
  alias Inconn2Service.InventoryManagement.{InventorySupplier, InventoryItem}
  alias Inconn2Service.InventoryManagement.{UomCategory, UnitOfMeasurement, Store}



  def list_uom_categories(prefix) do
    Repo.all(UomCategory, prefix: prefix)
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

  def delete_uom_category(%UomCategory{} = uom_category, prefix) do
    Repo.delete(uom_category, prefix: prefix)
  end

  def change_uom_category(%UomCategory{} = uom_category, attrs \\ %{}) do
    UomCategory.changeset(uom_category, attrs)
  end

  #Context functions for %UnitOfMeasurement{}
  def list_unit_of_measurements(%{"uom_category_id" => uom_category_id}, prefix) when not is_nil(uom_category_id) do
    from(uom in UnitOfMeasurement, where: uom.uom_category_id == ^uom_category_id)
    |> Repo.all(prefix: prefix) |> Repo.preload(:uom_category)
  end

  def list_unit_of_measurements(_query_params, prefix) do
    Repo.all(UnitOfMeasurement, prefix: prefix) |> Repo.preload(:uom_category)
  end

  def list_unit_of_measurements_by_uom_category(uom_category_id, prefix) do
    from(uom in UnitOfMeasurement, where: uom.uom_category_id == ^uom_category_id)
    |> Repo.all(prefix: prefix) |> Repo.preload(:uom_category)
  end

  def get_unit_of_measurement!(id, prefix), do: Repo.get!(UnitOfMeasurement, id, prefix: prefix)

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

  def delete_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, prefix) do
    Repo.delete(unit_of_measurement, prefix: prefix)
  end

  def change_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, attrs \\ %{}) do
    UnitOfMeasurement.changeset(unit_of_measurement, attrs)
  end

  # Context functions for %Store{}
  def list_stores(prefix) do
      Repo.all(Store, prefix: prefix)
      |> Stream.map(fn store -> preload_user_for_store({:ok, store}, prefix, "get") end)
      |> Enum.map(fn store -> preload_site_and_location_for_store({:ok, store}, prefix, "get") end)
  end

  def list_stores_by_site(site_id, prefix) do
    from(s in Store, where: s.site_id == ^site_id)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn store -> preload_user_for_store({:ok, store}, prefix, "get") end)
    |> Enum.map(fn store -> preload_site_and_location_for_store({:ok, store}, prefix, "get") end)
  end

  def list_stores_by_location(location_id, prefix) do
    from(s in Store, where: s.location_id == ^location_id)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn store -> preload_user_for_store({:ok, store}, prefix, "get") end)
    |> Enum.map(fn store -> preload_site_and_location_for_store({:ok, store}, prefix, "get") end)
  end

  def get_store!(id, prefix) do
    Repo.get!(Store, id, prefix: prefix)
    |> preload_site_and_location_for_store(prefix, "get")
    |> preload_user_for_store(prefix, "get")
  end

  def create_store(attrs \\ %{}, prefix) do
      %Store{}
      |> Store.changeset(read_attachment(attrs))
      |> Repo.insert(prefix: prefix)
      |> preload_site_and_location_for_store(prefix, "post")
      |> preload_user_for_store(prefix, "post")
  end

  def update_store(%Store{} = store, attrs, prefix) do
    store
    |> Store.update_changeset(read_attachment(attrs))
    |> Repo.update(prefix: prefix)
    |> preload_site_and_location_for_store(prefix, "post")
    |> preload_user_for_store(prefix, "post")
  end

  def delete_store(%Store{} = store, prefix) do
    Repo.delete(store, prefix: prefix)
  end

  def change_store(%Store{} = store, attrs \\ %{}) do
    Store.changeset(store, attrs)
  end

  #Context functions for %InventorySupplier{}
  def list_inventory_suppliers(prefix) do
    Repo.all(InventorySupplier, prefix: prefix)
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

  def delete_inventory_supplier(%InventorySupplier{} = inventory_supplier, prefix) do
    Repo.delete(inventory_supplier, prefix: prefix)
  end

  def change_inventory_supplier(%InventorySupplier{} = inventory_supplier, attrs \\ %{}) do
    InventorySupplier.changeset(inventory_supplier, attrs)
  end

  #Context functions for %InventoryItem{}
  def list_inventory_items(prefix) do
    Repo.all(InventoryItem, prefix: prefix)
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

  def delete_inventory_item(%InventoryItem{} = inventory_item, prefix) do
    Repo.delete(inventory_item, prefix: prefix)
  end

  def change_inventory_item(%InventoryItem{} = inventory_item, attrs \\ %{}) do
    InventoryItem.changeset(inventory_item, attrs)
  end

  #All private functions related to the context
  defp read_attachment(attrs) do
    attachment = Map.get(attrs, "attachment")
    if attachment != nil and attachment != "" do
      {:ok, attachment_binary} = File.read(attachment.path)
      attachment_type = attachment.content_type
      attrs
      |> Map.put("attachment", attachment_binary)
      |> Map.put("attachment_type", attachment_type)
    else
      attrs
    end
  end

  defp preload_user_for_store({:ok, store}, prefix, request_type) do
    if store.user_id != nil do
      case request_type do
        "post" -> {:ok, Map.put(store, :user, Staff.get_user_without_org_unit(store.user_id, prefix))}
         _ -> Map.put(store, :user, Staff.get_user_without_org_unit(store.user_id, prefix))
      end
    else
      case request_type do
        "post" -> {:ok, Map.put(store, :user, nil)}
        _ -> Map.put(store, :user, nil)
      end
    end
  end

  defp preload_user_for_store(result, _prefix, _request_type), do: result

  defp preload_site_and_location_for_store({:ok, store}, prefix, request_type) do
    cond do
      !is_nil(store.site_id) && !is_nil(store.location_id) ->
        site = AssetConfig.get_site!(store.site_id, prefix)
        location = AssetConfig.get_location!(store.site_id, prefix)
        case request_type do
          "post" -> {:ok, Map.put(store, :location, location) |> Map.put(:site, site)}
          _ -> Map.put(store, :location, location) |> Map.put(:site, site)
        end


      true ->
        case request_type do
          "post" -> {:ok, Map.put(store, :location, nil) |> Map.put(:site, nil)}
          _ -> Map.put(store, :location, nil) |> Map.put(:site, nil)
        end
    end
  end

  defp preload_site_and_location_for_store(result, _prefix, _request_type), do: result

  defp preload_uom_category({:ok, unit_of_measurement}), do: {:ok, unit_of_measurement |> Repo.preload(:uom_category)}

  defp preload_uom_category(result), do: result

end

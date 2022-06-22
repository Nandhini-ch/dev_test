defmodule Inconn2Service.InventoryManagement do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  import Ecto.Changeset
  alias Ecto.Multi

  alias Inconn2Service.{AssetConfig, Staff}
  alias Inconn2Service.InventoryManagement.{Conversion, InventorySupplier, InventoryItem, Store}
  alias Inconn2Service.InventoryManagement.{Stock, Transaction, UomCategory, UnitOfMeasurement}

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

  def update_unit_of_measurements(unit_of_measurements_changes, prefix) do
    Stream.map(unit_of_measurements_changes["ids"], fn id ->
      update_unit_of_measurement(get_unit_of_measurement!(id, prefix), Map.drop(unit_of_measurements_changes, ["ids"]), prefix)
    end) |> Enum.map(fn tuple -> remove_tuple_from_multiple_update(tuple) end)
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

  def update_inventory_suppliers(inventory_supplier_changes, prefix) do
    Enum.map(inventory_supplier_changes["ids"], fn id ->
      update_inventory_supplier(get_inventory_supplier!(id, prefix), Map.drop(inventory_supplier_changes, ["ids"]), prefix)
    end) |> Enum.map(fn tuple -> remove_tuple_from_multiple_update(tuple) end)
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
    |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement, :consume_unit_of_measurement, :uom_category])
    |> preload_asset_categories(prefix)
  end

  def get_inventory_item!(id, prefix) do
    Repo.get!(InventoryItem, id, prefix: prefix)
    |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement, :consume_unit_of_measurement, :uom_category])
    |> preload_asset_categories(prefix)
  end

  def create_inventory_item(attrs \\ %{}, prefix) do
    %InventoryItem{}
    |> InventoryItem.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_uoms_for_items()
    |> preload_uom_category()
    |> preload_asset_categories(prefix)
  end

  def update_inventory_items(inventory_item_changes, prefix) do
    Enum.map(inventory_item_changes["ids"], fn id ->
      update_inventory_item(get_inventory_item!(id, prefix), Map.drop(inventory_item_changes, ["ids"]), prefix)
    end) |> Enum.map(fn tuple -> remove_tuple_from_multiple_update(tuple) end)
  end

  def update_inventory_item(%InventoryItem{} = inventory_item, attrs, prefix) do
    inventory_item
    |> InventoryItem.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_uoms_for_items()
    |> preload_uom_category()
    |> preload_asset_categories(prefix)
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

  #Context functions for Transactions
  def list_transactions(prefix) do
    Repo.all(Transaction, prefix: prefix)
    |> Stream.map(fn t -> load_user_for_given_key(t, :approver_user_id, :approver_user, prefix) end)
    |> Enum.map(fn t -> load_user_for_given_key(t, :transaction_user_id, :transaction_user, prefix) end)
  end

  def list_transactions_to_be_acknowledged(user, prefix) do
    from(t in Transaction, where: t.transaction_user_id == ^user.id and t.is_acknowledged == "NACK")
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn t -> load_user_for_given_key(t, :approver_user_id, :approver_user, prefix) end)
    |> Enum.map(fn t -> load_user_for_given_key(t, :transaction_user_id, :transaction_user, prefix) end)
  end

  def list_transactions_to_be_approved(user, prefix) do
    from(t in Transaction, where: t.approve_user_id == ^user.id and t.is_approve == "NA")
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn t -> load_user_for_given_key(t, :approver_user_id, :approver_user, prefix) end)
    |> Enum.map(fn t -> load_user_for_given_key(t, :transaction_user_id, :transaction_user, prefix) end)
  end

  def get_transaction!(id, prefix) do
    Repo.get!(Transaction, id, prefix: prefix)
    |> load_user_for_given_key(:approver_user_id, :approver_user, prefix)
    |> load_user_for_given_key(:transaction_user_id, :transaction_user, prefix)
  end

  def create_transactions(transactions, prefix) do
    Enum.map(transactions, fn t ->
      create_transaction(t, prefix)
    end)
  end

  #Different create function based on transaction type
  def create_transaction(attrs \\ %{}, prefix) do
    case attrs["transaction_type"] do
      "IN" -> create_inward_transaction(attrs, prefix)
      "IS" -> create_issue_transaction(attrs, prefix)
    end
  end

  #Create for inward transaction
  def create_inward_transaction(attrs, prefix) do
    multi_query_for_inward_transaction(attrs, prefix)
    |> Repo.transaction()
    |> handle_error()
    |> load_user_for_given_key(:approver_user_id, :approver_user, prefix)
    |> load_user_for_given_key(:transaction_user_id, :transaction_user, prefix)
  end

  #Create for Issue Transaction
  def create_issue_transaction(attrs, prefix) do
    multi_query_for_issue_transaction(attrs, prefix)
    |> Repo.transaction()
    |> handle_error()
    |> load_user_for_given_key(:approver_user_id, :approver_user, prefix)
    |> load_user_for_given_key(:transaction_user_id, :transaction_user, prefix)
  end

  #Only time a stock can be updated is when issue acknowledgement happens
  def update_transaction(%Transaction{} = transaction, attrs, prefix) do
    transaction
    |> Transaction.update_changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> reduce_stock_on_approval(prefix)
    |> revive_stock_on_acknowledgement_reject(prefix)
    |> load_user_for_given_key(:approver_user_id, :approver_user, prefix)
    |> load_user_for_given_key(:transaction_user_id, :transaction_user, prefix)
  end

  def delete_transaction(%Transaction{} = transaction, prefix) do
    Repo.delete(transaction, prefix: prefix)
  end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  #Context functions for Stock
  def list_stocks(query_params, prefix) do
    stock_query(Stock, query_params ) |> Repo.all(prefix: prefix)
  end

  def get_stock!(id, prefix), do: Repo.get!(Stock, id, prefix: prefix)

  def create_stock(attrs \\ %{}, prefix) do
    %Stock{}
    |> Stock.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_stock(%Stock{} = stock, attrs, prefix) do
    stock
    |> Stock.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_stock(%Stock{} = stock, prefix) do
    Repo.delete(stock, prefix: prefix)
  end

  def change_stock(%Stock{} = stock, attrs \\ %{}) do
    Stock.changeset(stock, attrs)
  end

  #Context functions for conversion
  def list_conversions(prefix) do
    Repo.all(Conversion, prefix: prefix) |> preload_unit_of_measurement_and_category_for_conversion()
  end

  def get_conversion!(id, prefix), do: Repo.get!(Conversion, id, prefix: prefix) |> preload_unit_of_measurement_and_category_for_conversion()

  def create_conversion(attrs \\ %{}, prefix) do
    %Conversion{}
    |> Conversion.changeset(attrs)
    |> check_uom_conversion_units_in_category(prefix)
    |> Repo.insert(prefix: prefix)
    |> preload_unit_of_measurement_and_category_for_conversion()
  end

  def update_conversion(%Conversion{} = conversion, attrs, prefix) do
    conversion
    |> Conversion.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_unit_of_measurement_and_category_for_conversion()
  end

  def delete_conversion(%Conversion{} = conversion, prefix) do
    Repo.delete(conversion, prefix: prefix)
  end

  def change_conversion(%Conversion{} = conversion, attrs \\ %{}) do
    Conversion.changeset(conversion, attrs)
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

  defp preload_uoms_for_items({:ok, inventory_item}), do: {:ok, inventory_item |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement, :consume_unit_of_measurement])}
  defp preload_uoms_for_items(result), do: result

  defp preload_asset_categories({:error, reason}, _prefix), do: {:error, reason}
  defp preload_asset_categories({:ok, item}, prefix), do: {:ok, preload_asset_categories(item, prefix)}
  defp preload_asset_categories(items, prefix) when is_list(items), do: Enum.map(items, fn i -> preload_asset_categories(i, prefix) end)
  defp preload_asset_categories(item, prefix) when is_map(item), do: Map.put(item, :asset_categories, Enum.map(item.asset_category_ids, fn id -> AssetConfig.get_asset_category(id, prefix) end) |> Enum.filter(fn a -> not is_nil(a) end))

  defp preload_user_for_store({:error, reason}, _prefix), do: {:error, reason}
  defp preload_user_for_store({:ok, store}, prefix), do: {:ok, preload_user_for_store(store, prefix)}
  defp preload_user_for_store(store, _prefix) when is_nil(store.user_id), do: Map.put(store, :user, nil)
  defp preload_user_for_store(store, prefix), do: Map.put(store, :user, Staff.get_user_without_org_unit(store.user_id, prefix))

  defp preload_site_and_location_for_store({:error, reason}, _prefix), do: {:error, reason}
  defp preload_site_and_location_for_store({:ok, store}, prefix), do: {:ok, preload_site_and_location_for_store(store, prefix)}
  defp preload_site_and_location_for_store(store, _prefix) when is_nil(store.site_id) or is_nil(store.location_id), do:  Map.put(store, :location, nil) |> Map.put(:site, nil)
  defp preload_site_and_location_for_store(store, prefix), do: Map.put(store, :location, AssetConfig.get_location(store.location_id, prefix)) |> Map.put(:site, AssetConfig.get_site(store.site_id, prefix))


  defp preload_uom_category({:ok, resource}), do: {:ok, resource |> Repo.preload(:uom_category)}
  defp preload_uom_category(result), do: result

  defp handle_error({:error, :transaction, transaction_changeset, _}), do: {:error, transaction_changeset}
  defp handle_error({:error, :stock, stock_changeset, _}), do: {:error, stock_changeset}
  defp handle_error({:ok, %{transaction: transaction, stock: _stock}}), do: {:ok, transaction}

  defp load_user_for_given_key(transaction, id_key, new_key, prefix) when is_tuple(transaction), do: {:ok, Map.put(transaction, new_key, Staff.get_user_without_org_unit(transaction[id_key], prefix))}
  defp load_user_for_given_key(transaction, id_key, new_key, prefix), do: Map.put(transaction, new_key, Staff.get_user_without_org_unit(transaction[id_key], prefix))

  defp preload_unit_of_measurement_and_category_for_conversion({:error, changeset}), do: {:error, changeset}
  defp preload_unit_of_measurement_and_category_for_conversion({:ok, resource}), do: {:ok,preload_unit_of_measurement_and_category_for_conversion(resource)}
  defp preload_unit_of_measurement_and_category_for_conversion(resource), do: resource |> Repo.preload([:uom_category, :from_unit_of_measurement, :to_unit_of_measurement])

  defp stock_query(query, %{}), do: query
  defp stock_query(query, query_params), do: from(q in query, where: q.item_id == ^query_params["item_id"] and q.store_id == ^query_params["store_id"])

  defp get_uom_conversion_factor(from_uom_id, to_uom_id, _prefix, _inverse) when from_uom_id == to_uom_id, do: {:ok, 1}

  defp get_uom_conversion_factor(from_uom_id, to_uom_id,  prefix, inverse) do
    unit_of_measurement_conversion = uom_conversion_query(from_uom_id, to_uom_id) |> Repo.one(prefix: prefix)
    cond do
      is_nil(unit_of_measurement_conversion) and inverse -> {:error, "Conversion Not found"}
      is_nil(unit_of_measurement_conversion) -> get_uom_conversion_factor(to_uom_id, from_uom_id,  prefix, true)
      inverse -> {:ok, 1 / unit_of_measurement_conversion.multiplication_factor}
      true -> {:ok, unit_of_measurement_conversion.multiplication_factor}
    end
  end

  defp uom_conversion_query(from_uom_id, to_uom_id) do
    from(c in Conversion, where: c.from_unit_of_measurement_id == ^from_uom_id and c.to_unit_of_measurement_id == ^to_uom_id)
  end

  defp remove_tuple_from_multiple_update({:ok, resource}), do: resource

  defp stock_if_exists_upto_bin(store_id, aisle, bin, row, item_id, prefix) do
    stock_if_exists_query(store_id, aisle, bin, row, item_id) |> Repo.one(prefix: prefix)
  end

  defp stock_upto_store(store_id, item_id, prefix) do
    stock_if_exists_query(store_id, item_id) |> Repo.all(prefix: prefix)
  end

  defp stock_if_exists_query(store_id, aisle, bin, row, item_id) do
    from(
      s in Stock,
      where:
        s.inventory_item_id == ^item_id and
        s.store_id ==  ^store_id and
        s.aisle == ^aisle and
        s.row == ^row and
        s.bin == ^bin
    )
  end

  defp stock_if_exists_query(store_id, item_id) do
    from(s in Stock, where: s.item_id == ^item_id and s.store_id == ^store_id)
  end

  defp multi_query_for_inward_transaction(attrs, prefix) do
    Multi.new()
    |> Multi.run(:transaction, insert_inward_transaction(attrs, prefix))
    |>  Multi.run(:stock, update_stock_for_inward(prefix))
  end

  defp multi_query_for_issue_transaction(attrs, prefix) do
    Multi.new()
    |> Multi.run(:transaction, insert_issue_transaction(attrs, prefix))
    |> Multi.run(:stock, update_stock_for_issue(prefix))
  end

  defp insert_inward_transaction(attrs, prefix) do
    fn _, _ ->
      %Transaction{}
      |> Transaction.changeset(attrs)
      |> calculate_cost()
      |> convert_quantity(prefix)
      |> Repo.insert(prefix: prefix)
    end
  end

  defp insert_issue_transaction(attrs, prefix) do
    fn _, _ ->
      %Transaction{}
      |> Transaction.changeset(attrs)
      |> convert_quantity(prefix)
      |> check_stock_upto_store(prefix)
      |> check_stock_upto_bin(prefix)
      |> Repo.insert(prefix: prefix)
    end
  end

  defp calculate_cost(cs), do: change(cs, %{cost: get_field(cs, :unit_price) * get_field(cs, :quantity) })

  defp convert_quantity(cs, prefix) do
    inventory_item_id = get_field(cs, :inventory_item_id, nil)
    transaction_unit_of_measurement_id = get_field(cs, :unit_of_measurement_id, nil)
    item_unit_of_measurement_id = get_inventory_item!(inventory_item_id, prefix).inventory_unit_of_measurement_id
    case get_uom_conversion_factor(transaction_unit_of_measurement_id, item_unit_of_measurement_id, prefix, false) do
      {:ok, multiplication_factor} -> change(cs, %{quantity: get_field(cs, :quantity) * multiplication_factor})
      {:error, _reason} -> add_error(cs, :unit_of_measurement_id, "Conversion for given UOM to selected item's inventory UOM is not availabe")
    end
  end

  defp check_uom_conversion_units_in_category(cs, prefix) do
    from_uom = get_unit_of_measurement!(get_field(cs, :from_unit_of_measurement_id), prefix)
    to_uom = get_unit_of_measurement!(get_field(cs, :to_unit_of_measurement_id), prefix)
    uom_category_id = get_change(cs, :uom_category_id)
    cond do
      from_uom.uom_category_id == uom_category_id && to_uom.uom_category_id == uom_category_id -> cs
      true -> add_error(cs, :uom_category_ids, "One of the UOM does not belong to the given UOM Category")
    end
  end

  defp update_stock_for_inward(prefix) do
    fn _repo, %{transaction: transaction} ->
      stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.item_id, prefix)
      case stock do
        nil ->
          create_stock(
            %{
              "inventory_item_id" => transaction.inventory_item_id,
              "store_id" => transaction.store_id,
              "aisle" => transaction.aisle,
              "bin" => transaction.bin,
              "row" => transaction.row,
              "quantity" => transaction.quantity
            },
            prefix
          )
        _ ->
          update_stock(stock, %{"quantity" => stock.quantity + transaction.quantity}, prefix)
      end
    end
  end

  defp update_stock_for_issue(prefix) do
    fn _, %{transaction: transaction} ->
      cond do
        transaction.is_approval_required ->
          {:ok, %{message: "Approval required for transaction"}}

        true ->
          # stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.item_id, prefix)
          # update_stock(stock, %{"quantity" => stock.quantity - transaction.quantity}, prefix)
          reduce_stock(transaction, prefix)
      end
    end
  end

  defp reduce_stock_on_approval({:ok, transaction}, prefix) do
    cond do
      transaction.is_approval_required && transaction.is_approved ->
        reduce_stock(transaction, prefix)
        {:ok, transaction}

      true ->
        {:ok, transaction}
    end
  end

  defp reduce_stock_on_approval(result, _prefix), do: result

  defp revive_stock_on_acknowledgement_reject({:ok, transaction}, prefix) do
    case transaction.is_acknowledged do
      "YES" ->
        {:ok, transaction}

      "RJ" ->
        # stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.item_id, prefix)
        # update_stock(stock, %{"quantity" => stock.quantity + transaction.quantity}, prefix)
        add_stock(transaction, prefix)
        {:ok, transaction}

      _ ->
        {:ok, transaction}
    end
  end

  defp revive_stock_on_acknowledgement_reject(result, _prefix), do: result

  defp add_stock(transaction, prefix) do
    stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.item_id, prefix)
    update_stock(stock, %{"quantity" => stock.quantity + transaction.quantity}, prefix)
  end

  defp reduce_stock(transaction, prefix) do
    stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.item_id, prefix)
    update_stock(stock, %{"quantity" => stock.quantity - transaction.quantity}, prefix)
  end

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

  defp check_stock_upto_store(cs, prefix) do
    stocks = stock_upto_store(get_field(cs, :store_id), get_field(cs, :item_id), prefix)
    case length(stocks) do
      0 -> add_error(cs, :item_id, "Item does not exist in store") |> add_error(:store_id, "Item does not exist in store")
      _ -> cs
    end
  end

  defp check_stock_upto_bin(cs, prefix) do
    store_id = get_field(cs, :store_id)
    aisle = get_field(cs, :aisle)
    row = get_field(cs, :row)
    bin = get_field(cs, :bin)
    item_id = get_field(cs, :item_id)
    quantity = get_field(cs, :quantity)
    stock = stock_if_exists_upto_bin(store_id, aisle, bin, row, item_id, prefix)
    cond do
      is_nil(stock) ->
        add_error(cs, :item_id, "Item does not exist in this aisle row bin combination")

      stock.quantity < quantity ->
        add_error(cs, :quantity, "Expected quantity not available")

       true ->
        cs
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

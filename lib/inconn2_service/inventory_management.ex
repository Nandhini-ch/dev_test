defmodule Inconn2Service.InventoryManagement do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  import Inconn2Service.Util.IndexQueries
  import Inconn2Service.Util.HelpersFunctions

  alias Ecto.Multi
  alias Inconn2Service.Repo

  alias Inconn2Service.{AssetConfig, Staff}
  alias Inconn2Service.InventoryManagement.{Conversion, InventorySupplier, InventorySupplierItem, InventoryItem, Store}
  alias Inconn2Service.InventoryManagement.{Stock, SiteStock, Transaction, UomCategory, UnitOfMeasurement}

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

      has_stock?(unit_of_measurement, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as the UOM has items that have associated with it"
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
  def list_stores(query_params, prefix, user \\ %{}) do
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

      {"storekeeper_user_id", "current"}, query ->
        from q in query, where: q.storekeeper_user_id == ^user.id

      {"storekeeper_user_id", storekeeper_user_id}, query ->
        from q in query, where: q.storekeeper_user_id == ^storekeeper_user_id

      {"storekeeper_user_ids", storekeeper_user_ids}, query ->
        from q in query, where: q.storekeeper_user_id in ^storekeeper_user_ids

     _ , query ->
        query
    end) |> add_active_condition()
    Repo.all(query, prefix: prefix)
      |> Stream.map(fn store -> preload_user_for_store(store, prefix) end)
      |> Stream.map(fn store -> preload_storekeeper_user_for_store(store, prefix) end)
      |> Enum.map(fn store -> preload_site_and_location_for_store(store, prefix) end)
  end

  def list_stores_by_site(site_id, prefix) do
    from(s in Store, where: s.site_id == ^site_id and s.active)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn store -> preload_user_for_store(store, prefix) end)
    |> Stream.map(fn store -> preload_storekeeper_user_for_store(store, prefix) end)
    |> Enum.map(fn store -> preload_site_and_location_for_store(store, prefix) end)
  end

  def list_stores_by_location(location_id, prefix) do
    from(s in Store, where: s.location_id == ^location_id and s.active)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn store -> preload_user_for_store(store, prefix) end)
    |> Stream.map(fn store -> preload_storekeeper_user_for_store(store, prefix) end)
    |> Enum.map(fn store -> preload_site_and_location_for_store(store, prefix) end)
  end

  def get_store!(id, prefix) do
    Repo.get!(Store, id, prefix: prefix)
    |> preload_site_and_location_for_store(prefix)
    |> preload_user_for_store(prefix)
    |> preload_storekeeper_user_for_store(prefix)
  end

  def create_store(attrs \\ %{}, prefix) do
      %Store{}
      |> Store.changeset(read_attachment(attrs))
      |> Repo.insert(prefix: prefix)
      |> preload_site_and_location_for_store(prefix)
      |> preload_user_for_store(prefix)
      |> preload_storekeeper_user_for_store(prefix)
  end

  def update_store(%Store{} = store, attrs, prefix) do
    store
    |> Store.update_changeset(read_attachment(attrs))
    |> Repo.update(prefix: prefix)
    |> preload_site_and_location_for_store(prefix)
    |> preload_user_for_store(prefix)
    |> preload_storekeeper_user_for_store(prefix)
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
    |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement, :consume_unit_of_measurement, :uom_category])
    |> preload_asset_categories(prefix)
  end

  def list_inventory_items(query_params, prefix) do
    inventory_item_query(from(i in InventoryItem, where: i.active), query_params)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement])
    |> Repo.preload([:consume_unit_of_measurement, :uom_category, :inventory_supplier_items])
    |> Repo.preload([stocks: :store])
    |> preload_asset_categories(prefix)
    |> filter_on_supplier(query_params["supplier_id"])
    # |> preload_stocked_quantity_for_item(query_params["location_id"])
    |> Enum.map(fn i -> preload_stocked_quantity_for_item(i, query_params["location_id"]) end)
  end

  def list_inventory_items_for_store_keeper(query_params, user, prefix) do
    from(i in InventoryItem, where: i.active,
    join: st in Stock, on: i.id == st.inventory_item_id,
    join: s in Store, on: s.id == st.store_id, where: s.user_id == ^user.id,
    select: i)
    |> inventory_item_query(query_params)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement])
    |> Repo.preload([:consume_unit_of_measurement, :uom_category, :inventory_supplier_items])
    |> Repo.preload([stocks: :store])
    |> preload_asset_categories(prefix)
    |> filter_on_supplier(query_params["supplier_id"])
    # |> preload_stocked_quantity_for_item(query_params["location_id"])
    |> Enum.map(fn i -> preload_stocked_quantity_for_item(i, query_params["location_id"]) end)
  end

  def get_inventory_item!(id, prefix) do
    IO.inspect(prefix)
    Repo.get!(InventoryItem, id, prefix: prefix)
    |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement])
    |> Repo.preload([:consume_unit_of_measurement, :uom_category])
    |> Repo.preload(stocks: :store)
    |> preload_asset_categories(prefix)
    |> preload_stocked_quantity_for_item(nil)
  end

  def create_inventory_item(attrs \\ %{}, prefix) do
    %InventoryItem{}
    |> InventoryItem.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_uoms_for_items()
    |> preload_uom_category()
    |> preload_stocks_for_items()
    |> preload_stocked_quantity_for_item(nil)
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
    |> preload_stocks_for_items()
    |> preload_stocked_quantity_for_item(nil)
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
  def list_transactions(query_params, prefix) do
    transactions_query(Transaction, query_params)
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Enum.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
  end

  def list_transactions_grouped(query_params, prefix) do
    transactions_query(Transaction, query_params)
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Stream.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
    |> Stream.map(fn t -> get_stock_for_item_and_store(t, prefix) end)
    |> Enum.group_by(&(&1.transaction_reference))
    |> rearrange_transaction_info()
    |> put_approval_status_for_transactions()
  end

  defp get_stock_for_item_and_store(transaction, prefix) do
    stock_query(
      Stock,
      %{
        "item_id" => transaction.inventory_item_id,
        "store_id" => transaction.store_id
      }
    ) |> Repo.all(prefix: prefix) |> Enum.map(fn s -> s.quantity end) |> Enum.sum() |> put_current_stock_for_transaction_result(transaction)
  end

  defp put_current_stock_for_transaction_result(stock, transaction), do: Map.put(transaction, :current_stock, stock)

  defp rearrange_transaction_info(transactions) do
    Enum.map(transactions, fn {reference, transactions_for_reference} ->
      first_transaction = List.first(transactions_for_reference)
      %{
        reference_no: reference,
        date: first_transaction.transaction_date,
        transaction_type: first_transaction.transaction_type,
        transaction_user: first_transaction.transaction_user,
        transactions: transactions_for_reference,
      }
    end)
  end

  defp put_approval_status_for_transactions(transactions) do
    Enum.map(transactions, fn t -> put_approval_status(t, t.transaction_type) end)
  end

  defp put_approval_status(transaction, "IN") do
    Map.put(transaction, :status, "Completed")
  end

  defp put_approval_status(transaction, "IS") do
    statuses = Enum.map(transaction.transactions, fn x -> x.status end)
    is_approved_statuses = Enum.filter(transaction.transactions, fn x -> x.is_approval_required and x.is_approved == "AP" end)
    cond do
      "APRJ" in statuses or length(is_approved_statuses) > 0 ->
        Map.put(transaction, :status, "Rejected")

      true ->
        Map.put(transaction, :status, "Created")
    end
  end

  def list_transactions_to_be_acknowledged(user, prefix) do
    from(t in Transaction, where: t.transaction_user_id == ^user.id and t.is_acknowledged != "ACK" and t.status == "ACKP")
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Enum.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
  end

  def list_transactions_to_be_approved(user, prefix) do
    from(t in Transaction, where: t.approver_user_id == ^user.id and t.is_approved == "NA")
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Enum.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
  end

  def list_transactions_to_be_approved_grouped(user, prefix) do
    from(t in Transaction, where: t.approver_user_id == ^user.id and t.status == "NA" and t.is_approved != "AP")
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Stream.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
    |> Enum.group_by(&(&1.transaction_reference))
    |> rearrange_transaction_info()
    |> put_approval_status_for_transactions()
  end

  def list_pending_transactions_approval_for_my_teams(user, prefix) do
    teams = Staff.get_team_ids_for_user(user, prefix)
    team_user_ids = Staff.get_team_users(teams, prefix) |> Enum.map(fn u -> u.id end)
    from(t in Transaction, where: t.approver_user_id in ^team_user_ids and t.status == "NA" and t.is_approved != "AP")
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Stream.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
    |> Enum.group_by(&(&1.transaction_reference))
    |> rearrange_transaction_info()
    |> put_approval_status_for_transactions()
  end

  def list_transactions_for_team(user, prefix) do
    teams = Staff.get_team_ids_for_user(user, prefix)
    team_user_ids = Staff.get_team_users(teams, prefix) |> Enum.map(fn u -> u.id end)
    store_ids = list_stores(%{"storekeeper_user_ids" => team_user_ids}, prefix) |> Enum.map(fn s -> s.id end)
    from(t in Transaction, where: t.store_id in ^store_ids)
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Stream.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
    |> Enum.group_by(&(&1.transaction_reference))
    |> rearrange_transaction_info()
    |> put_approval_status_for_transactions()
  end

  def list_transactions_submitted_for_approved_grouped(user, prefix) do
    from(t in Transaction, where: t.transaction_user_id == ^user.id and t.status == "NA" and t.is_approved != "AP")
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Stream.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
  end


  def list_pending_transactions_to_be_approved(user, prefix) do
    from(t in Transaction, where: t.transaction_user_id == ^user.id and t.is_approved != "AP")
    |> Repo.all(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> Stream.map(fn t -> load_approver_user_for_transaction(t, prefix) end)
    |> Enum.map(fn t -> load_transaction_user_for_transaction(t, prefix) end)
  end

  def get_transaction!(id, prefix) do
    Repo.get!(Transaction, id, prefix: prefix)
    |> preload_stuff_for_transaction()
    |> load_approver_user_for_transaction(prefix)
    |> load_transaction_user_for_transaction(prefix)
  end

  def create_transactions(transactions, prefix) do
    result =
      Enum.map(transactions, fn t ->
        create_transaction(t, prefix)
      end)
    error_case = Enum.map(result, fn {a, b} -> if a == :error do b end end) |> Enum.filter(fn e -> !is_nil(e) end)
    IO.inspect(error_case)
    case length(error_case) do
      0 -> {:ok, result |> Enum.map(fn {:ok, r} -> r end)}
      _ ->  {:multiple_error, error_case}
    end
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
    |> preload_stuff_for_transaction()
    |> load_approver_user_for_transaction(prefix)
    |> load_transaction_user_for_transaction(prefix)
  end

  #Create for Issue Transaction
  def create_issue_transaction(attrs, prefix) do
    multi_query_for_issue_transaction(attrs, prefix)
    |> Repo.transaction()
    |> handle_error()
    |> preload_stuff_for_transaction()
    |> load_approver_user_for_transaction(prefix)
    |> load_transaction_user_for_transaction(prefix)
  end

  #Only time a stock can be updated is when issue acknowledgement happens
  def update_transaction(%Transaction{} = transaction, attrs, prefix) do
    transaction
    |> Transaction.update_changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_stuff_for_transaction()
    |> reduce_stock_on_approval(prefix)
    |> revive_stock_on_acknowledgement_reject(prefix)
    |> load_approver_user_for_transaction(prefix)
    |> load_transaction_user_for_transaction(prefix)
  end

  def approve_transactions(attrs, prefix, user) do
    query = from(t in Transaction, where: t.transaction_reference == ^attrs["reference"] and t.approver_user_id == ^user.id)
    Repo.update_all(query, [set: [is_approved: attrs["status"], status: "AP"]], prefix: prefix)
    Repo.all(query, prefix: prefix)
  end

  def issue_approved_transactions(attrs, prefix) do
    query = from(t in Transaction, where: t.transaction_reference == ^attrs["reference"])
    # Repo.update_all(query, [set: [is_approved: "AP", status: "AP"]], prefix: prefix)
    transactions = Repo.all(query, prefix: prefix)
    Enum.map(transactions,fn t -> update_transaction(t, %{"status" => "ACKP"}, prefix) end)
    |> Enum.map(fn {:ok, transaction} -> transaction end)
  end

  #Transaction cannot be deleted
  # def delete_transaction(%Transaction{} = transaction, prefix) do
  #   Repo.delete(transaction, prefix: prefix)
  # end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  #Context functions for Stock
  def list_stocks(query_params, prefix) do
    stock_query(Stock, query_params ) |> Repo.all(prefix: prefix)|> Repo.preload([:store, inventory_item: :inventory_unit_of_measurement])
  end

  def list_stocks_for_storekeeper(user, prefix) do
    store_ids = list_stores(%{"storekeeper_user_id" => user.id}, prefix) |> Enum.map(fn s -> s.id end)
    list_stocks(%{"store_ids" => store_ids}, prefix)
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

  #Stocks cannot be deleted
  # def delete_stock(%Stock{} = stock, prefix) do
  #   Repo.delete(stock, prefix: prefix)
  # end

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

  #Context functions for inventory supplier items
  def list_inventory_supplier_items(prefix, query_params) do
    inventory_supplier_item_query(InventorySupplierItem, query_params) |> Repo.all(prefix: prefix)
  end

  def get_inventory_supplier_item!(id, prefix), do: Repo.get!(InventorySupplierItem, id, prefix: prefix)

  def create_inventory_supplier_item(attrs \\ %{}, prefix) do
    %InventorySupplierItem{}
    |> InventorySupplierItem.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_inventory_supplier_item(%InventorySupplierItem{} = inventory_supplier_item, attrs, prefix) do
    inventory_supplier_item
    |> InventorySupplierItem.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_inventory_supplier_item(%InventorySupplierItem{} = inventory_supplier_item, prefix) do
    Repo.delete(inventory_supplier_item, prefix: prefix)
  end

  def change_inventory_supplier_item(%InventorySupplierItem{} = inventory_supplier_item, attrs \\ %{}) do
    InventorySupplierItem.changeset(inventory_supplier_item, attrs)
  end

  #Context functions for site stocks
  def list_site_stocks(prefix) do
    Repo.all(SiteStock, prefix: prefix)
  end

  def get_site_stock!(id, prefix), do: Repo.get!(SiteStock, id, prefix: prefix)

  def create_site_stock(attrs \\ %{}, prefix) do
    %SiteStock{}
    |> SiteStock.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_site_stock(%SiteStock{} = site_stock, attrs, prefix) do
    site_stock
    |> SiteStock.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_site_stock(%SiteStock{} = site_stock, prefix) do
    Repo.delete(site_stock, prefix: prefix)
  end

  def change_site_stock(%SiteStock{} = site_stock, attrs \\ %{}) do
    SiteStock.changeset(site_stock, attrs)
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

  defp stock_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"item_id", item_id}, query -> from q in query, where: q.inventory_item_id == ^item_id
      {"store_id", store_id}, query -> from q in query, where: q.store_id == ^store_id
      {"store_ids", store_ids}, query -> from q in query, where: q.store_id in ^store_ids
      _, query -> query
    end)
  end

  defp inventory_supplier_item_query(query, %{}), do: add_active_condition(query)

  defp inventory_supplier_item_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"inventory_supplier_id", inventory_supplier_id}, query  -> from q in query, where: q.inventory_supplier_id == ^inventory_supplier_id
      {"inventory_item_id", inventory_item_id}, query -> from q in query, where: q.inventory_item_id == ^inventory_item_id
      _ , query -> query
      end) |> add_active_condition()
  end

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

  defp stock_if_exists_upto_bin(store_id, nil, nil, nil, item_id, prefix) do
    stock_if_exists_query(store_id, item_id) |> Repo.one(prefix: prefix)
  end

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
    from(s in Stock, where: s.inventory_item_id == ^item_id and s.store_id == ^store_id)
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
      |> check_for_approval_flow(prefix)
      |> check_store_layout_config(prefix)
      |> calculate_cost()
      |> convert_quantity(prefix)
      |> put_inward_status()
      |> Repo.insert(prefix: prefix)
      |> create_supplier_item_record(prefix)
      |> update_site_level_stock(prefix)
    end
  end

  defp put_inward_status(cs), do: change(cs, %{status: "CP"})

  defp check_for_approval_flow(cs, prefix) do
    is_transaction_approval_required = get_field(cs, :is_approval_required, nil)
    approver_user_id = get_field(cs, :approver_user_id, nil)
    item = get_field(cs, :inventory_item_id) |> get_inventory_item!(prefix)

    cond do
      is_transaction_approval_required && is_nil(approver_user_id) && !is_nil(item.approval_user_id) -> change(cs, %{approver_user_id: item.approval_user_id, is_approved: "NA", status: "NA"})
      is_transaction_approval_required && !is_nil(approver_user_id) -> change(cs, %{status: "NA", is_approved: "NA"})
      is_transaction_approval_required && is_nil(approver_user_id) -> validate_required(cs, [:approver_user_id])
      !is_transaction_approval_required -> change(cs, %{status: "ACKP"})
      true -> cs
    end
  end

  defp create_supplier_item_record({:ok, transaction}, prefix) do
    query =
      from si in InventorySupplierItem, where:
        si.inventory_supplier_id == ^transaction.inventory_supplier_id and
        si.inventory_item_id == ^transaction.inventory_item_id

    case Repo.one(query, prefix: prefix) do
      nil ->
        create_inventory_supplier_item(
            %{
              "inventory_item_id" => transaction.inventory_item_id,
              "inventory_supplier_id" => transaction.inventory_supplier_id
            },
            prefix
        )
        {:ok, transaction}

      _ ->
       {:ok, transaction}
    end
  end

  defp create_supplier_item_record(result, _prefix), do: result

  defp insert_issue_transaction(attrs, prefix) do
    fn _, _ ->
      %Transaction{}
      |> Transaction.changeset(attrs)
      |> check_store_layout_config(prefix)
      |> calculate_cost()
      |> convert_quantity(prefix)
      |> check_stock_upto_store(prefix)
      |> check_stock_upto_bin(prefix)
      |> check_for_approval_flow(prefix)
      |> Repo.insert(prefix: prefix)
      |> update_site_level_stock(prefix)
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
      stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.inventory_item_id, prefix)
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
        transaction.is_approval_required -> {:ok, %{message: "Approval required for transaction"}}
        true -> reduce_stock(transaction, prefix)
      end
    end
  end

  defp reduce_stock_on_approval({:ok, transaction}, prefix) do
    cond do
      transaction.status == "AP" ->
        reduce_stock(transaction, prefix)
        {:ok, transaction}

      true ->
        {:ok, transaction}
    end
  end

  defp reduce_stock_on_approval(result, _prefix), do: result

  defp revive_stock_on_acknowledgement_reject({:ok, transaction}, prefix) do
    case transaction.is_acknowledged do
      "ACK" ->
        {:ok, transaction}

      "RJ" ->
        add_stock(transaction, prefix)
        {:ok, transaction}

      _ ->
        {:ok, transaction}
    end
  end

  defp revive_stock_on_acknowledgement_reject(result, _prefix), do: result

  defp add_stock(transaction, prefix) do
    stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.inventory_item_id, prefix)
    update_stock(stock, %{"quantity" => stock.quantity + transaction.quantity}, prefix)
  end

  defp reduce_stock(transaction, prefix) do
    stock = stock_if_exists_upto_bin(transaction.store_id, transaction.aisle, transaction.bin, transaction.row, transaction.inventory_item_id, prefix)
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
    stocks = stock_upto_store(get_field(cs, :store_id), get_field(cs, :inventory_item_id), prefix)
    case length(stocks) do
      0 -> add_error(cs, :inventory_item_id, "Item does not exist in store") |> add_error(:store_id, "Item does not exist in store")
      _ -> cs
    end
  end

  defp check_store_layout_config(cs, prefix) do
    store = get_store!(get_field(cs, :store_id), prefix)
    cond do
      store.is_layout_configuration_required and is_nil(get_field(cs, :aisle)) and is_nil(get_field(cs, :bin)) and is_nil(get_field(cs, :row)) ->
        add_error(cs, :aisle, "Aisle is required") |> add_error(:bin, "Bin is Required") |> add_error(:row, "Row is Required")

      store.is_layout_configuration_required ->
        validate_aisle(cs, prefix) |> validate_bin(prefix) |> validate_row(prefix)

      true ->cs
    end
  end

  defp validate_aisle(cs, prefix) do
    store = get_store!(get_field(cs, :store_id), prefix)
    notation = store.aisle_notation
    validate_notation(cs, :aisle, notation, prefix)
  end

  defp validate_row(cs, prefix) do
    store = get_store!(get_field(cs, :store_id), prefix)
    notation = store.row_notation
    validate_notation(cs, :row, notation, prefix)
  end

  defp validate_bin(cs, prefix) do
    store = get_store!(get_field(cs, :store_id), prefix)
    notation = store.bin_notation
    validate_notation(cs, :bin, notation, prefix)
  end

  defp validate_notation(cs, key, notation, _prefix) do
    case notation do
      "U" -> match_case(cs, key, ~r/^[A-Z]/)
      "L" -> match_case(cs, key, ~r/^[a-z]/ )
      "N" -> match_case(cs, key, ~r/[^a-zA-Z]/)
      _ -> cs
    end
  end

  def match_case(cs, key, regex) do
    case String.match?(get_field(cs, key), regex) do
      true -> cs
      _ -> add_error(cs, key, "Not in required notation")
    end
  end

  defp check_stock_upto_bin(cs, prefix) do
    store_id = get_field(cs, :store_id)
    aisle = get_field(cs, :aisle)
    row = get_field(cs, :row)
    bin = get_field(cs, :bin)
    item_id = get_field(cs, :inventory_item_id)
    quantity = get_field(cs, :quantity)
    stock = stock_if_exists_upto_bin(store_id, aisle, bin, row, item_id, prefix)
    cond do
      is_nil(stock) ->
        add_error(cs, :inventory_item_id, "Item does not exist in this aisle row bin combination")

      stock.quantity < quantity ->
        IO.inspect(stock.quantity)
        IO.inspect(quantity)
        add_error(cs, :quantity, "Expected quantity not available")

       true ->
        cs
    end
  end

  defp check_for_items_with_uom_query(unit_of_measurement) do
    from(i in InventoryItem,
      where:
            (i.consume_unit_of_measurement_id == ^unit_of_measurement.id or
             i.inventory_unit_of_measurement_id == ^unit_of_measurement.id or
             i.purchase_unit_of_measurement_id == ^unit_of_measurement.id) and
             i.active == true
            )
  end

  defp has_items?(unit_of_measurement, prefix) do
    item_query = check_for_items_with_uom_query(unit_of_measurement)
    case length(Repo.all(item_query, prefix: prefix)) do
      0 -> false
      _ -> true
    end
  end

  defp update_site_level_stock({:error, changeset}, _prefix), do: {:error, changeset}

  defp update_site_level_stock({:ok, transaction}, prefix) do
     Elixir.Task.start(fn ->
      create_or_update_site_stock(transaction, prefix)
    end)
    {:ok, transaction}
  end

  defp create_or_update_site_stock(transaction, prefix) do
    site_id = get_store!(transaction.store_id, prefix).site_id
    item = get_inventory_item!(transaction.inventory_item_id, prefix)
    query = get_site_stock_check_query(transaction, site_id)
    quantity = get_stock_for_site(site_id, transaction.inventory_item_id, prefix)
    {is_msl_breached, date_time} = check_msl_breach(site_id, item, quantity, prefix)
    case Repo.one(query, prefix: prefix) do
      nil ->
        create_site_stock(%{
          "inventory_item_id" => transaction.inventory_item_id,
          "site_id" => site_id,
          "quantity" => quantity,
          "unit_of_measurement_id" => item.inventory_unit_of_measurement_id,
          "is_msl_breached" => is_msl_breached,
          "breached_date_time" => date_time
        }, prefix)
      entry ->
        update_store(
          entry,
          %{
            "is_msl_breached" => is_msl_breached,
            "breached_date_time" => date_time
          },
          prefix
        )
    end
  end

  defp check_msl_breach(site_id, item, quantity, prefix) do
    cond do
      quantity < item.minimum_stock_level -> {"YES", get_site_date_time_now(site_id, prefix)}
      true -> {"NO", nil}
    end
  end

  defp get_stock_for_site(site_id, item_id, prefix) do
    from(s in Store, where: s.site_id == ^site_id,
         join: st in Stock, on: st.inventory_item_id == ^item_id and st.store_id == s.id,
         select: st
    )
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn st -> st.quantity end)
    |> Enum.sum()
  end

  def get_site_stock_check_query(transaction, site_id) do
    from(ss in SiteStock, where:
         ss.inventory_item_id == ^transaction.inventory_item_id and
         ss.site_id == ^site_id)
  end

  defp preload_uoms_for_items({:ok, inventory_item}), do: {:ok, inventory_item |> Repo.preload([:inventory_unit_of_measurement, :purchase_unit_of_measurement, :consume_unit_of_measurement])}
  defp preload_uoms_for_items(result), do: result

  defp preload_stocks_for_items({:error, reason}), do: {:error, reason}
  defp preload_stocks_for_items({:ok, item}), do: {:ok, preload_stocks_for_items(item)}
  defp preload_stocks_for_items(item), do: item |> Repo.preload([stocks: :store])

  defp preload_stocked_quantity_for_item({:error, reason}, _location_id), do: {:error, reason}
  defp preload_stocked_quantity_for_item({:ok, item}, _location_id), do: {:ok, preload_stocked_quantity_for_item(item, nil)}
  defp preload_stocked_quantity_for_item(item, nil), do: Map.put(item, :stocked_quantity, load_stock(item, nil))
  defp preload_stocked_quantity_for_item(item, location_id), do: Map.put(item, :stocked_quantity, load_stock(item, location_id))

  defp preload_asset_categories({:error, reason}, _prefix), do: {:error, reason}
  defp preload_asset_categories({:ok, item}, prefix), do: {:ok, preload_asset_categories(item, prefix)}
  defp preload_asset_categories(items, prefix) when is_list(items), do: Enum.map(items, fn i -> preload_asset_categories(i, prefix) end)
  defp preload_asset_categories(item, prefix) when is_map(item), do: Map.put(item, :asset_categories, Enum.map(item.asset_category_ids, fn id -> AssetConfig.get_asset_category(id, prefix) end) |> Enum.filter(fn a -> not is_nil(a) end))

  defp preload_user_for_store({:error, reason}, _prefix), do: {:error, reason}
  defp preload_user_for_store({:ok, store}, prefix), do: {:ok, preload_user_for_store(store, prefix)}
  defp preload_user_for_store(store, _prefix) when is_nil(store.user_id), do: Map.put(store, :user, nil)
  defp preload_user_for_store(store, prefix), do: Map.put(store, :user, Staff.get_user_without_org_unit(store.user_id, prefix))

  defp preload_storekeeper_user_for_store({:error, reason}, _prefix), do: {:error, reason}
  defp preload_storekeeper_user_for_store({:ok, store}, prefix), do: {:ok, preload_storekeeper_user_for_store(store, prefix)}
  defp preload_storekeeper_user_for_store(store, _prefix) when is_nil(store.storekeeper_user_id), do: Map.put(store, :storekeeper_user, nil)
  defp preload_storekeeper_user_for_store(store, prefix), do: Map.put(store, :storekeeper_user, Staff.get_user_without_org_unit(store.storekeeper_user_id, prefix))

  defp preload_site_and_location_for_store({:error, reason}, _prefix), do: {:error, reason}
  defp preload_site_and_location_for_store({:ok, store}, prefix), do: {:ok, preload_site_and_location_for_store(store, prefix)}
  defp preload_site_and_location_for_store(store, _prefix) when is_nil(store.site_id) or is_nil(store.location_id), do:  Map.put(store, :location, nil) |> Map.put(:site, nil)
  defp preload_site_and_location_for_store(store, prefix), do: Map.put(store, :location, AssetConfig.get_location(store.location_id, prefix)) |> Map.put(:site, AssetConfig.get_site(store.site_id, prefix))

  defp preload_uom_category({:ok, resource}), do: {:ok, resource |> Repo.preload(:uom_category)}
  defp preload_uom_category(result), do: result

  defp handle_error({:error, :transaction, transaction_changeset, _}), do: {:error, transaction_changeset}
  defp handle_error({:error, :stock, stock_changeset, _}), do: {:error, stock_changeset}
  defp handle_error({:ok, %{transaction: transaction, stock: _stock}}), do: {:ok, transaction}

  defp load_approver_user_for_transaction({:ok, transaction}, prefix), do: {:ok, load_approver_user_for_transaction(transaction, prefix)}
  defp load_approver_user_for_transaction({:error, changeset}, _prefix), do: {:error, changeset}
  defp load_approver_user_for_transaction(transaction, prefix), do: Map.put(transaction, :approver_user, Staff.get_user_without_org_unit(transaction.approver_user_id, prefix))

  defp load_transaction_user_for_transaction({:ok, transaction}, prefix), do: {:ok, load_transaction_user_for_transaction(transaction, prefix)}
  defp load_transaction_user_for_transaction({:error, changeset}, _prefix), do: {:error, changeset}
  defp load_transaction_user_for_transaction(transaction, prefix), do: Map.put(transaction, :transaction_user, Staff.get_user_without_org_unit(transaction.transaction_user_id, prefix))

  defp preload_unit_of_measurement_and_category_for_conversion({:error, changeset}), do: {:error, changeset}
  defp preload_unit_of_measurement_and_category_for_conversion({:ok, resource}), do: {:ok,preload_unit_of_measurement_and_category_for_conversion(resource)}
  defp preload_unit_of_measurement_and_category_for_conversion(resource), do: resource |> Repo.preload([:uom_category, :from_unit_of_measurement, :to_unit_of_measurement])

  defp preload_stuff_for_transaction({:error, changeset}), do: {:error, changeset}
  defp preload_stuff_for_transaction({:ok, transaction}), do: {:ok, preload_stuff_for_transaction(transaction)}
  defp preload_stuff_for_transaction(transaction), do: transaction |> Repo.preload([:unit_of_measurement, :store, inventory_item: :inventory_unit_of_measurement])

  defp load_stock(inventory_item, nil),do: sum_stock_quantities(inventory_item.stocks)
  defp load_stock(inventory_item, store_id), do: Stream.filter(inventory_item.stocks, fn i -> i.store_id == store_id end) |> sum_stock_quantities()

  defp filter_on_supplier(items, nil), do: items
  defp filter_on_supplier(items, supplier_id), do: Enum.filter(items, fn i -> i.supplier_items.inventory_supplier_id == supplier_id end)

  defp sum_stock_quantities(stocks), do: Stream.map(stocks, fn s -> s.quantity end) |> Enum.sum()

  defp has_stock?(%Store{} = store, prefix), do: (stock_query(Stock, %{"store_id" => store.id}) |> Repo.all(prefix: prefix) |> length())  > 0
  defp has_stock?(%InventoryItem{} = item, prefix), do: (stock_query(Stock, %{"item_id" => item.id}) |> Repo.all(prefix: prefix) |> length())  > 0
  defp has_stock?(%UnitOfMeasurement{} = uom, prefix), do: (check_for_items_with_uom_query(uom) |> Repo.all(prefix: prefix) |> Repo.preload(:stocks)  |> Stream.map(fn i -> i.stock.quantity end) |> Enum.sum()) > 0

  defp has_transaction?(%UnitOfMeasurement{} = unit_of_measurement, prefix), do: (transactions_query(Transaction, %{"unit_of_measurement_id" => unit_of_measurement.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  defp has_transaction?(%InventoryItem{} = item, prefix), do: (transactions_query(Transaction, %{"item_id" => item.id}) |> Repo.all(prefix: prefix) |> length()) > 0
  defp has_transaction?(%InventorySupplier{} = supplier, prefix), do: (transactions_query(Transaction, %{"supplier_id" => supplier.id}) |> Repo.all(prefix: prefix) |> length()) > 0

  defp add_active_condition(query), do: from q in query, where: q.active == true
end

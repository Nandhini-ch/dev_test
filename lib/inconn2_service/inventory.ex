defmodule Inconn2Service.Inventory do

  import Ecto.Query, warn: false
  alias Inconn2Service.Ticket.CategoryHelpdesk
  alias Inconn2Service.Repo
  import Ecto.Changeset

  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.Prompt
  alias Inconn2Service.Common

  alias Inconn2Service.Inventory.{Supplier, SupplierItem}

  alias Ecto.Multi

  def list_suppliers(prefix) do
    Repo.all(Supplier, prefix: prefix)
  end

  def get_supplier!(id, prefix), do: Repo.get!(Supplier, id, prefix: prefix)


  def create_supplier(attrs \\ %{}, prefix) do
    %Supplier{}
    |> Supplier.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end


  def update_supplier(%Supplier{} = supplier, attrs, prefix) do
    supplier
    |> Supplier.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_supplier(%Supplier{} = supplier, prefix) do
    Repo.delete(supplier, prefix: prefix)
  end

  def change_supplier(%Supplier{} = supplier, attrs \\ %{}) do
    Supplier.changeset(supplier, attrs)
  end

  alias Inconn2Service.Inventory.UOM


  def list_uoms(prefix) do
    Repo.all(UOM, prefix: prefix)
  end

  def list_physical_uoms(prefix) do
    Repo.get_by(UOM, [uom_type: "physical"], prefix: prefix)
  end

  def list_cost_uoms(prefix) do
    Repo.get_by(UOM, [uom_type: "cost"], prefix: prefix)
  end

  def get_uom!(id, prefix), do: Repo.get!(UOM, id, prefix: prefix)

  def get_uom_by_name(nil, _prefix), do: []

  def get_uom_by_name(name, prefix) do
    from(u in UOM, where: u.name == ^name)
    |> Repo.all(prefix: prefix)
  end

  def validate_name_constraint_in_uom(cs, prefix) do
    name = get_change(cs, :name, prefix)
    uom_name_list = get_uom_by_name(name, prefix)
    case length(uom_name_list) do
      0 -> cs
      1 -> add_error(cs, :name, "UOM name is already exists")
    end
  end

  def create_uom(attrs \\ %{}, prefix) do
    %UOM{}
    |> UOM.changeset(attrs)
    |> validate_name_constraint_in_uom(prefix)
    |> Repo.insert(prefix: prefix)
  end

  def update_uom(%UOM{} = uom, attrs, prefix) do
    uom
    |> UOM.changeset(attrs)
    |> validate_name_constraint_in_uom(prefix)
    |> Repo.update(prefix: prefix)
  end

  def delete_uom(%UOM{} = uom, prefix) do
    Repo.delete(uom, prefix: prefix)
  end

  def change_uom(%UOM{} = uom, attrs \\ %{}) do
    UOM.changeset(uom, attrs)
  end

  alias Inconn2Service.Inventory.UomConversion

  def list_uom_conversions(prefix) do
    Repo.all(UomConversion, prefix: prefix)
  end

  def get_uom_conversion!(id, prefix), do: Repo.get!(UomConversion, id, prefix: prefix)

  def convert(from_uom_id, to_uom_id, value, prefix, direction \\ "forward") do
    record = Repo.get_by(UomConversion, [from_uom_id: from_uom_id, to_uom_id: to_uom_id], prefix: prefix)
    case direction do
      "forward" ->
        case record do
          nil ->
            convert(from_uom_id, to_uom_id, value, prefix, "reverse")

          record ->
            {:ok , %{converted_value: String.to_integer(value) * record.mult_factor}}
        end
      "reverse" ->
        case record do
          nil ->
           {:error, :not_found}

          record ->
           {:ok, %{converted_value: value * record.inverse_factor}}
        end
    end
  end

  def get_unique_category_helpdesk(nil, nil, nil,  _prefix), do: []

  def get_unique_category_helpdesk(user_id, site_id, workrequest_category_id, prefix) do
    from(c in CategoryHelpdesk, where: c.user_id == ^user_id and c.site_id == ^site_id and c.workrequest_category_id == ^workrequest_category_id and c.active == true)
    |> Repo.all(prefix: prefix)
  end

  def validate_category_helpdesk_constraint(cs, prefix) do
    user_id = get_change(cs, :user_id, nil)
    site_id = get_change(cs, :site_id, nil)
    workrequest_category_id = get_change(cs, :workrequest_category_id, nil)
    unique_list = get_unique_category_helpdesk(user_id, site_id, workrequest_category_id, prefix)
    case length(unique_list) do
      0 -> cs
      1 -> add_error(cs, :code, "This Category Helpdesk is already taken")
    end
  end

  def create_uom_conversion(attrs \\ %{}, prefix) do
    %UomConversion{}
    |> UomConversion.changeset(attrs)
    |> set_inverse_field()
    |> validate_category_helpdesk_constraint(prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp set_inverse_field(cs) do
    inverse_factor = get_field(cs, :inverse_factor, nil)
    if inverse_factor == nil do
      mult_factor = get_field(cs, :mult_factor, nil)
      change(cs, %{inverse_factor: 1/mult_factor})
    else
      cs
    end
  end


  def update_uom_conversion(%UomConversion{} = uom_conversion, attrs, prefix) do
    uom_conversion
    |> UomConversion.changeset(attrs)
    |> validate_category_helpdesk_constraint(prefix)
    |> Repo.update(prefix: prefix)
  end

  def delete_uom_conversion(%UomConversion{} = uom_conversion, prefix) do
    Repo.delete(uom_conversion, prefix: prefix)
  end

  def change_uom_conversion(%UomConversion{} = uom_conversion, attrs \\ %{}) do
    UomConversion.changeset(uom_conversion, attrs)
  end

  alias Inconn2Service.Inventory.Item


  def list_items(prefix) do
    Repo.all(Item, prefix: prefix) |> Repo.preload([:inventory_unit_uom, :purchase_unit_uom, :consume_unit_uom])
  end

  def list_items_by_type(prefix, type) do
    Item
    |> where(type: ^type)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:inventory_unit_uom, :purchase_unit_uom, :consume_unit_uom])
  end

  def get_item!(id, prefix) do
    Repo.get!(Item, id, prefix: prefix) |> Repo.preload([:inventory_unit_uom, :purchase_unit_uom, :consume_unit_uom])
  end

  def create_item(attrs \\ %{}, prefix) do
    result =
      %Item{}
      |> Item.changeset(attrs)
      |> validate_asset_categories_ids(prefix)
      # |> validate_uom_for_key(prefix, :purchase_unit_uom_id)
      # |> validate_uom_for_key(prefix, :inventory_unit_uom_id)
      # |> validate_uom_for_key(prefix, :consume_unit_uom_id)
      |> Repo.insert(prefix: prefix)

    case result do
      {:ok, item} -> {:ok, item |> Repo.preload([:inventory_unit_uom, :purchase_unit_uom, :consume_unit_uom])}
      _ -> result
    end

  end

  defp validate_asset_categories_ids(cs, prefix) do
    ids = get_change(cs, :asset_categories, nil)
    if ids != nil do
      asset_categories = from(a in AssetCategory, where: a.id in ^ids )
              |> Repo.all(prefix: prefix)
      case length(ids) == length(asset_categories) do
        true -> cs
        false -> add_error(cs, :asset_categories, "Asset Categories are invalid")
      end
    else
      cs
    end
  end

  defp validate_uom_for_key(cs, prefix, key) do
    unit_id = get_field(cs, key, nil)
    unit_uom = Repo.get(UOM, unit_id, prefix: prefix)
    IO.inspect(unit_uom)
    case unit_uom do
      %Inconn2Service.Inventory.UOM{} ->
        cs

      _ ->
        add_error(cs, key, "Invalid Unit Uom")
    end
  end

  def update_item(%Item{} = item, attrs, prefix) do
    result =
      item
      |> Item.changeset(attrs)
      |> Repo.update(prefix: prefix)

    case result do
      {:ok, item} -> {:ok, item |> Repo.preload([:inventory_unit_uom, :purchase_unit_uom, :consume_unit_uom], force: true)}
      _ -> result
    end
  end


  def delete_item(%Item{} = item, prefix) do
    Repo.delete(item, prefix: prefix)
  end


  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  alias Inconn2Service.Inventory.InventoryLocation

  def list_inventory_locations(prefix) do
    Repo.all(InventoryLocation, prefix: prefix)
  end

  def get_inventory_location!(id, prefix), do: Repo.get!(InventoryLocation, id, prefix: prefix)

  def create_inventory_location(attrs \\ %{}, prefix) do
    %InventoryLocation{}
    |> InventoryLocation.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end


  def update_inventory_location(%InventoryLocation{} = inventory_location, attrs, prefix) do
    inventory_location
    |> InventoryLocation.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_inventory_location(%InventoryLocation{} = inventory_location, prefix) do
    Repo.delete(inventory_location, prefix: prefix)
  end

  def change_inventory_location(%InventoryLocation{} = inventory_location, attrs \\ %{}) do
    InventoryLocation.changeset(inventory_location, attrs)
  end

  alias Inconn2Service.Inventory.InventoryStock


  def list_inventory_stocks(prefix) do
    Repo.all(InventoryStock, prefix: prefix)
  end

  def list_inventory_stocks(inventory_location_id, prefix) do
    InventoryStock
    |> where(inventory_location_id: ^inventory_location_id)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:inventory_location, item: [:inventory_unit_uom, :consume_unit_uom, :purchase_unit_uom ]])
  end


  def get_inventory_stock!(id, prefix), do: Repo.get!(InventoryStock, id, prefix: prefix) |> Repo.preload([:inventory_location, item: [:inventory_unit_uom, :consume_unit_uom, :purchase_unit_uom ]])

  def get_stock_for_item(item_id, prefix) do
    supplier_items =
      SupplierItem
      |> where(item_id: ^item_id)
      |> Repo.all(prefix: prefix)

    sum = Enum.map(supplier_items, fn s -> s.price end) |> Enum.sum()
    IO.inspect(sum)
    IO.inspect(length(supplier_items))
    average = sum / length(supplier_items)
    stock = Repo.get_by(InventoryStock, [item_id: item_id], prefix: prefix) |> Repo.preload([:inventory_location, item: [:inventory_unit_uom, :consume_unit_uom, :purchase_unit_uom ]])
    Map.put_new(stock, :price, average)
  end


  def create_inventory_stock(attrs \\ %{}, prefix) do
    %InventoryStock{}
    |> InventoryStock.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end


  def update_inventory_stock(%InventoryStock{} = inventory_stock, attrs, prefix) do
    inventory_stock
    |> InventoryStock.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end


  def delete_inventory_stock(%InventoryStock{} = inventory_stock, prefix) do
    Repo.delete(inventory_stock, prefix: prefix)
  end


  def change_inventory_stock(%InventoryStock{} = inventory_stock, attrs \\ %{}) do
    InventoryStock.changeset(inventory_stock, attrs)
  end

  alias Inconn2Service.Inventory.InventoryTransaction

  def list_inventory_transactions(prefix) do
    Repo.all(InventoryTransaction, prefix: prefix)
  end

  def list_inventory_transactions_by_transaction_type(prefix, transaction_type) do
    InventoryTransaction
    |> where(transaction_type: ^transaction_type)
    |> Repo.all(prefix: prefix)
  end


  def get_inventory_transaction!(id, prefix), do: Repo.get!(InventoryTransaction, id, prefix: prefix)|> Repo.preload([:inventory_location, item: [:inventory_unit_uom, :consume_unit_uom, :purchase_unit_uom ]])


  def create_inward_transaction_list("IN", dc_date, dc_reference, supplier_id, transactions, prefix) do
    {:ok,
      Enum.map(transactions, fn(t) ->
        modified_transaction = t
                                |> Map.put("dc_reference", dc_reference)
                                |> Map.put("dc_date", dc_date)
                                |> Map.put("transaction_type", "IN")
                                |> Map.put("supplier_id", supplier_id)
        {:ok, transaction} = create_inventory_transaction(modified_transaction, prefix)
        transaction
      end)
    }

  end

  def create_issue_transaction_list("IS", workorder_id, reference_no, authorized_by, user_id ,transactions, prefix) do
    IO.inspect("workorder: #{workorder_id}")
    IO.inspect("authorized_by: #{authorized_by}")
    IO.inspect("reference_no: #{reference_no}")
    IO.inspect("user_id: #{user_id}")

    {:ok,
      Enum.map(transactions, fn(t) ->
        modified_transaction =
          t
          |> Map.put("workorder_id", workorder_id)
          |> Map.put("transaction_type", "IS")
          |> Map.put("reference_no", reference_no)
          |> Map.put("authorized_by_user_id", authorized_by)
          |> Map.put("user_id", user_id)
        IO.inspect(modified_transaction)
        {:ok, transaction} = create_inventory_transaction(modified_transaction, prefix)
        transaction
      end)
    }
  end

  def create_purchase_return_transaction_list("PRT", gate_pass_reference, gate_pass_date, transactions, prefix) do
    {:ok,
      Enum.map(transactions, fn(t) ->
        modified_transaction = t
                                |> Map.put("gate_pass_reference", gate_pass_reference)
                                |> Map.put("gate_pass_date", gate_pass_date)
                                |> Map.put("transaction_type", "PRT")
        {:ok, transaction} = create_inventory_transaction(modified_transaction, prefix)
        transaction
      end)
    }

  end

  def create_out_transaction_list("OUT", gate_pass_reference, gate_pass_date, transactions, prefix) do
    {:ok,
      Enum.map(transactions, fn(t) ->
        modified_transaction = t
                                |> Map.put("gate_pass_reference", gate_pass_reference)
                                |> Map.put("gate_pass_date", gate_pass_date)
                                |> Map.put("transaction_type", "OUR")
        {:ok, transaction} = create_inventory_transaction(modified_transaction, prefix)
        transaction
      end)
    }
  end

  def create_intr_transaction_list("INTR", gate_pass_reference, gate_pass_date, transactions, prefix) do
    {:ok,
      Enum.map(transactions, fn(t) ->
        modified_transaction = t
                                |> Map.put("gate_pass_reference", gate_pass_reference)
                                |> Map.put("gate_pass_date", gate_pass_date)
                                |> Map.put("transaction_type", "INTR")
        {:ok, transaction} = create_inventory_transaction(modified_transaction, prefix)
        transaction
      end)
    }
  end

  def create_inis_transaction_list("INIS", issue_reference, user_id, transactions, prefix) do
    {:ok,
      Enum.map(transactions, fn(t) ->
        modified_transaction = t
                                |> Map.put("issue_reference", issue_reference)
                                |> Map.put("user_id", user_id)
                                |> Map.put("transaction_type", "INIS")
        {:ok, transaction} = create_inventory_transaction(modified_transaction, prefix)
        transaction
      end)
    }
  end

  def create_inventory_transaction(attrs \\ %{}, prefix) do
    # inventory_transaction = %InventoryTransaction{} |> InventoryTransaction.changeset(attrs)
    multi = Multi.new()
    |> Multi.insert(:inventory_transaction, InventoryTransaction.changeset(%InventoryTransaction{}, attrs)
    |> calculate_cost(prefix)
    |> auto_fill_site_id(prefix)
    |> validate_presence_in_database(prefix), prefix: prefix)
    |> Multi.run(:inventory_stock, fn repo, %{inventory_transaction: inventory_transaction} ->
      inventory_stock = repo.get_by(InventoryStock, [inventory_location_id: inventory_transaction.inventory_location_id, item_id: inventory_transaction.item_id], prefix: prefix)
      case inventory_transaction.transaction_type do
        "IN" ->
          handle_purchase_for_inventory_transaction(inventory_stock, inventory_transaction, prefix)

        "RT" ->
          handle_return_for_inventory_transaction(inventory_stock, inventory_transaction, prefix)

        "IS" ->
          handle_issue_for_inventory_transaction(inventory_stock, inventory_transaction, prefix)

        "PRT" ->
          handle_purchase_return_for_inventory_transaction(inventory_stock, inventory_transaction, prefix)

        "OUT" ->
          handle_out_for_inventory_transaction(inventory_stock, inventory_transaction, prefix)

        "INTR" ->
          handle_inward_transfer_for_inventory_transaction(inventory_stock, inventory_transaction, prefix)

        "INIS" ->
          handle_inward_issue_for_inventory_transaction(inventory_stock, inventory_transaction, prefix)
      end
    end)

    case Repo.transaction(multi) do
      {:ok, %{inventory_transaction: inventory_transaction, inventory_stock: _inventory_stock}} ->
        {:ok, inventory_transaction} = push_alert_for_notification(inventory_transaction, prefix)
        {:ok, inventory_transaction |> Repo.preload([:inventory_location, item: [:inventory_unit_uom, :consume_unit_uom, :purchase_unit_uom ]])}

      {:error, :inventory_transaction, inventory_transaction_changeset, _} ->
        {:error, inventory_transaction_changeset}
    end
  end

  def push_alert_for_notification(transaction, prefix) do
      item = get_item!(transaction.item_id, prefix)
      stock = get_stock_for_item(transaction.item_id, prefix)
    cond do
      stock.quantity <= item.reorder_quantity && item.critical ->
        description = ~s(Critical Item #{item.name} below reorder quantity)
        create_alert_for_inventory("INCB", description, prefix)

      stock.quantity <= item.reorder_quantity ->
        description = ~s(Item #{item.name} below reorder quantity)
         create_alert_for_inventory("INSB", description, prefix)

      true ->
        {:ok, transaction}
    end
    {:ok, transaction}
  end

  def create_alert_for_inventory(alert_code, description, prefix) do
    alert = Common.get_alert_by_code(alert_code)
    alert_config = Prompt.get_alert_notification_config_by_alert_id(alert.id, prefix)
    case alert_config do
      nil ->
        {:not_found, "Alert Not Configured"}

      _ ->
        attrs = %{
          "alert_notification_id" => alert.id,
          "type" => alert.type,
          "description" => description
        }

        Enum.map(alert_config.user_ids, fn id ->
          Prompt.create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
        end)
    end
  end

  def handle_purchase_for_inventory_transaction(inventory_stock, inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)
    # IO.inspect(item)
    # convert_for_transaction(item.purchase_unit_uom_id, item.inventory_unit_uom_id, quantity)

    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
        "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
        |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "IN")
        |> Repo.insert(prefix: prefix)

      inventory_stock ->
        inventory_stock
        |> InventoryStock.changeset(%{})
        |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "IN")
        |> Repo.update(prefix: prefix)
    end
  end

  def handle_inward_transfer_for_inventory_transaction(inventory_stock, inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)
    # IO.inspect(item)
    # convert_for_transaction(item.purchase_unit_uom_id, item.inventory_unit_uom_id, quantity)

    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
        "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
        |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "INTR")
        |> Repo.insert(prefix: prefix)

      inventory_stock ->
        inventory_stock
        |> InventoryStock.changeset(%{})
        |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "INTR")
        |> Repo.update(prefix: prefix)
    end
  end


  def convert_for_transaction_forward(cs, uom_id1, uom_id2, quantity, _prefix, transaction_type) when uom_id1 == uom_id2 do
    # quantity = get_field(cs, :quantity, nil)
    change(cs, %{quantity: update_for_transaction_type(transaction_type, quantity, 1)})
  end

  def convert_for_transaction_forward(cs, uom_id1, uom_id2, quantity, prefix, transaction_type) do
    case Repo.get_by(UomConversion, [from_uom_id: uom_id1, to_uom_id: uom_id2], prefix: prefix) do
      nil ->
        convert_for_transaction_reverse(cs, uom_id2, uom_id1, quantity, prefix, transaction_type)

      uom_conversion ->
        # quantity = get_field(cs, :quantity, nil)
        change(cs, %{quantity: update_for_transaction_type(transaction_type, quantity, uom_conversion.mult_factor)})
    end
  end

  def convert_for_transaction_reverse(cs, uom_id1, uom_id2, quantity, prefix, transaction_type) do
    case Repo.get_by(UomConversion, [from_uom_id: uom_id1, to_uom_id: uom_id2], prefix: prefix) do
      nil ->
        add_error(cs, :quantity, "Uom Conversion not present")

      uom_conversion ->
        # quantity = get_field(cs, :quantity, nil)
        change(cs, %{quantity: update_for_transaction_type(transaction_type, quantity, uom_conversion.inverse_factor)})
    end
  end

  # def convert_for_transaction(cs, uom_id1, uom_id2, quantity, prefix, direction \\ "forward", transaction_type \\ "IN") do
  #   uom_conversion = Repo.get_by(UomConversion, [from_uom_id: uom_id1, to_uom_id: uom_id2], prefix: prefix)
  #   case direction do
  #     "forward" ->
  #       case uom_conversion do
  #         nil ->
  #           convert_for_transaction(cs, uom_id2, uom_id1, quantity, prefix, "reverse")

  #         uom_conversion ->
  #           # quantity = get_field(cs, :quantity, nil)
  #           change(cs, %{quantity: update_for_transaction_type(transaction_type, quantity, uom_conversion.mult_factor)})
  #       end

  #     "reverse" ->
  #       case uom_conversion do
  #         nil ->
  #           add_error(cs, :quantity, "Uom Conversion not present")

  #         uom_conversion ->
  #           # quantity = get_field(cs, :quantity, nil)
  #           change(cs, %{quantity: update_for_transaction_type(transaction_type, quantity, uom_conversion.inverse_factor)})
  #       end
  #   end
  # end

  def update_for_transaction_type(transaction_type, quantity, factor) do
    case transaction_type do
      "IN" ->
        quantity * factor

      "IS" ->
        quantity - quantity * factor

      "PRT" ->
        quantity - quantity * factor

      "OUT" ->
        quantity - quantity * factor

      "RT" ->
        quantity + quantity * factor

      "INTR" ->
        quantity + quantity * factor

      "INIS" ->
        quantity - quantity * factor
    end
  end

  def handle_purchase_return_for_inventory_transaction(inventory_stock, inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)

    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
        "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
        |> force_error("No record found to return in stock")
        |> Repo.insert(prefix: prefix)

      inventory_stock ->
        if inventory_stock.quantity < inventory_transaction.quantity do
          InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
          "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
          |> force_error("Required Quantity Not found")
          |> Repo.insert(prefix: prefix)
        else
          inventory_stock
          |> InventoryStock.changeset(%{})
          |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "PRT")
          |> Repo.update(prefix: prefix)
        end
    end
  end

  def handle_out_for_inventory_transaction(inventory_stock, inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)

    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
        "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
        |> force_error("No record found to return in stock")
        |> Repo.insert(prefix: prefix)

      inventory_stock ->
        if inventory_stock.quantity < inventory_transaction.quantity do
          InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
          "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
          |> force_error("Required Quantity Not found")
          |> Repo.insert(prefix: prefix)
        else
          inventory_stock
          |> InventoryStock.changeset(%{})
          |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "OUT")
          |> Repo.update(prefix: prefix)
        end
    end
  end

  def handle_return_for_inventory_transaction(inventory_stock, inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)

    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
        "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
        |> force_error("No record found to return in stock")
        |> Repo.insert(prefix: prefix)

      inventory_stock ->
        inventory_stock
        |> InventoryStock.changeset(%{})
        |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "RT")
        |> Repo.update(prefix: prefix)
    end
  end

  def handle_issue_for_inventory_transaction(inventory_stock, inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)

    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
        "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
        |> force_error("No record found to return in stock")
        |> Repo.insert(prefix: prefix)

      inventory_stock ->
        if inventory_stock.quantity < inventory_transaction.quantity do
          InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
          "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
          |> force_error("Required Quantity Not found")
          |> Repo.insert(prefix: prefix)
        else
          inventory_stock
          |> InventoryStock.changeset(%{})
          |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "IS")
          |> Repo.update(prefix: prefix)
        end
    end
  end

  def handle_inward_issue_for_inventory_transaction(inventory_stock, inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)

    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
        "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
        |> force_error("No record found to return in stock")
        |> Repo.insert(prefix: prefix)

      inventory_stock ->
        if inventory_stock.quantity < inventory_transaction.quantity do
          InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transaction.inventory_location_id,
          "item_id" => inventory_transaction.item_id, "quantity" => inventory_transaction.quantity})
          |> force_error("Required Quantity Not found")
          |> Repo.insert(prefix: prefix)
        else
          inventory_stock
          |> InventoryStock.changeset(%{})
          |> convert_for_transaction_forward(inventory_transaction.uom_id, item.inventory_unit_uom_id, inventory_transaction.quantity, prefix, "IS")
          |> Repo.update(prefix: prefix)
        end
    end
  end



  def force_error(cs, error_msg) do
    add_error(cs, :quantity, error_msg)
  end


  def validate_presence_in_database(cs, prefix) do
    inventory_location_id = get_field(cs, :inventory_location_id, nil)
    changeset =
      case Repo.get(InventoryLocation, inventory_location_id, prefix: prefix) do
        nil ->
          add_error(cs, :inventory_location_id, "Iventory Location ID not valid")

        _ ->
          cs
      end
    item_id = get_field(changeset, :item_id, nil)
      case Repo.get(Item, item_id, prefix: prefix) do
        nil ->
          add_error(changeset, :item_id, "Item ID not valid")

        _ ->
          changeset
      end
      supplier_id = get_field(changeset, :supplier_id, nil)
      case Repo.get(Supplier, supplier_id, prefix: prefix) do
        nil ->
          add_error(changeset, :supplier_id, "Supplier ID not valid")

        _ ->
          changeset
      end
  end

  defp auto_fill_site_id(cs, prefix) do
    inventory_location_id = get_change(cs, :inventory_location_id, nil)
    if inventory_location_id != nil do
      inventory_location = Inconn2Service.Inventory.get_inventory_location!(inventory_location_id, prefix)
      change(cs, %{site_id: inventory_location.site_id})
    else
      cs
    end
  end

  defp calculate_cost(cs, prefix)  do
    case get_field(cs, :transaction_type, nil) do
      "IN" ->
        supplier_id = get_field(cs, :supplier_id, nil)
        item_id = get_field(cs, :item_id, nil)
        quantity = get_field(cs, :quantity, nil)
        IO.inspect("Supplier Id: #{supplier_id}")
        IO.inspect("Item Id: #{item_id}")
        if supplier_id != nil && item_id != nil do
          case Repo.get_by(SupplierItem, [supplier_id: supplier_id, item_id: item_id], prefix: prefix) do
            nil ->
              add_error(cs, :supplier_id, "Item Not Found for selected supplier")

            supplier_item ->
              IO.inspect("Supplier Item price: #{supplier_item.price * quantity}")
              changeset = change(cs, %{cost: supplier_item.price * quantity, cost_unit_uom_id: supplier_item.price_unit_uom_id, remaining: quantity})
              IO.inspect(changeset)
          end
        else
          cs
        end
      "IS" ->
        item_id = get_field(cs, :item_id, nil)
        quantity = get_field(cs, :quantity, nil)
        query = from(u in InventoryTransaction,
                    where: u.item_id == ^item_id and
                           u.transaction_type == "IN" and
                           u.remaining >= ^quantity,
                           order_by: [desc: u.inserted_at], limit: 1)
        required_issue_transaction = Repo.one(query, prefix: prefix)
        supplier_id = required_issue_transaction.supplier_id
        item_id = get_field(cs, :item_id, nil)
        if supplier_id != nil && item_id != nil do
          case Repo.get_by(SupplierItem, [supplier_id: supplier_id, item_id: item_id], prefix: prefix) do
            nil ->
              add_error(cs, :supplier_id, "Item Not Found for selected supplier")

            supplier_item ->
              IO.inspect("Supplier Item price: #{supplier_item.price * quantity}")
              update_inventory_transaction(required_issue_transaction, %{"remaining" => required_issue_transaction.remaining - quantity}, prefix)
              change(cs, %{cost: supplier_item.price * quantity, cost_unit_uom_id: supplier_item.price_unit_uom_id, supplier_id: required_issue_transaction.supplier_id})
              # IO.inspect(changeset)
          end
        else
          cs
        end
      "INIS" ->
        item_id = get_field(cs, :item_id, nil)
        quantity = get_field(cs, :quantity, nil)
        query = from(u in InventoryTransaction,
                    where: u.item_id == ^item_id and
                           u.transaction_type == "IS" and
                           u.remaining > ^quantity,
                           order_by: [desc: u.inserted_at], limit: 1)
        required_issue_transaction = Repo.one(query, prefix: prefix)
        supplier_id = required_issue_transaction.supplier_id
        item_id = get_field(cs, :item_id, nil)
        if supplier_id != nil && item_id != nil do
          case Repo.get_by(SupplierItem, [supplier_id: supplier_id, item_id: item_id], prefix: prefix) do
            nil ->
              add_error(cs, :supplier_id, "Item Not Found for selected supplier")

            supplier_item ->
              IO.inspect("Supplier Item price: #{supplier_item.price * quantity}")
              update_inventory_transaction(required_issue_transaction, %{"remaining" => required_issue_transaction.remaining - quantity}, prefix)
              change(cs, %{cost: supplier_item.price * quantity, cost_unit_uom_id: supplier_item.price_unit_uom_id, supplier_id: required_issue_transaction.supplier_id})
              # IO.inspect(changeset)
          end
        else
          cs
        end
        item_id = get_field(cs, :item_id, nil)
        quantity = get_field(cs, :quantity, nil)
        query = from(u in InventoryTransaction,
                    where: u.item_id == ^item_id and
                           u.transaction_type == "IS" and
                           u.remaining > ^quantity,
                           order_by: [desc: u.inserted_at], limit: 1)
        required_issue_transaction = Repo.one(query, prefix: prefix)
        supplier_id = required_issue_transaction.supplier_id
        item_id = get_field(cs, :item_id, nil)
        if supplier_id != nil && item_id != nil do
          case Repo.get_by(SupplierItem, [supplier_id: supplier_id, item_id: item_id], prefix: prefix) do
            nil ->
              add_error(cs, :supplier_id, "Item Not Found for selected supplier")

            supplier_item ->
              IO.inspect("Supplier Item price: #{supplier_item.price * quantity}")
              update_inventory_transaction(required_issue_transaction, %{"remaining" => required_issue_transaction.remaining - quantity}, prefix)
              change(cs, %{cost: supplier_item.price * quantity, cost_unit_uom_id: supplier_item.price_unit_uom_id, supplier_id: required_issue_transaction.supplier_id})
              # IO.inspect(changeset)
          end
        else
          cs
        end
      "PRT" ->
          item_id = get_field(cs, :item_id, nil)
          quantity = get_field(cs, :quantity, nil)
          query = from(u in InventoryTransaction,
                      where: u.item_id == ^item_id and
                             u.transaction_type == "IN" and
                             u.remaining > ^quantity, order_by: [desc: u.inserted_at],
                             limit: 1)
          IO.inspect(Repo.one(query, prefix: prefix))
          required_issue_transaction = Repo.one(query, prefix: prefix)
          supplier_id = required_issue_transaction.supplier_id
          item_id = get_field(cs, :item_id, nil)
          if supplier_id != nil && item_id != nil do
            case Repo.get_by(SupplierItem, [supplier_id: supplier_id, item_id: item_id], prefix: prefix) do
              nil ->
                add_error(cs, :supplier_id, "Item Not Found for selected supplier")

              supplier_item ->
                IO.inspect("Supplier Item price: #{supplier_item.price * quantity}")
                update_inventory_transaction(required_issue_transaction, %{"remaining" => required_issue_transaction.remaining - quantity}, prefix)
                change(cs, %{cost: supplier_item.price * quantity, cost_unit_uom_id: supplier_item.price_unit_uom_id, supplier_id: required_issue_transaction.supplier_id})
                # IO.inspect(changeset)
            end
          else
            cs
          end
      _ ->
        cs
    end
  end

  # def create_inventory_transaction(attrs \\ %{}, prefix) do
  #   %InventoryTransaction{}
  #   |> InventoryTransaction.changeset(attrs)
  #   |> Repo.insert(prefix: prefix)
  # end


  def update_inventory_transaction(%InventoryTransaction{} = inventory_transaction, attrs, prefix) do
    inventory_transaction
    |> InventoryTransaction.update_changeset(attrs)
    |> Repo.update(prefix: prefix)
  end


  def delete_inventory_transaction(%InventoryTransaction{} = inventory_transaction, prefix) do
    Repo.delete(inventory_transaction, prefix: prefix)
  end

  def change_inventory_transaction(%InventoryTransaction{} = inventory_transaction, attrs \\ %{}) do
    InventoryTransaction.changeset(inventory_transaction, attrs)
  end

  alias Inconn2Service.Inventory.InventoryTransfer

  def list_inventory_transfers(prefix) do
    Repo.all(InventoryTransfer, prefix: prefix)
  end

  def list_inventory_transactions_for_inventory_location(inventory_location_id, prefix) do
    InventoryTransaction
    |> where(inventory_location_id: ^inventory_location_id)
    |> Repo.all(prefix: prefix)
  end

  def get_item_for_transaction(inventory_transaction, prefix) do
    item = Repo.get(Item, inventory_transaction.item_id, prefix: prefix)
    Map.put(inventory_transaction, :item, item)
  end

  def list_inventory_transactions_for_inventory_location_and_type(inventory_location_id, prefix, transaction_type) do
    InventoryTransaction
    |> where([inventory_location_id: ^inventory_location_id, transaction_type: ^transaction_type])
    |> Repo.all(prefix: prefix)
  end

  def list_inventory_transfer_for_inventory_location(inventory_location_id, prefix) do
    InventoryTransfer
    |> where(from_location_id: ^inventory_location_id)
    |> Repo.all(prefix: prefix)
  end


  def get_inventory_transfer!(id, prefix), do: Repo.get!(InventoryTransfer, id, prefix: prefix)

  def create_inventory_transfer(attrs \\ %{}, prefix) do
    inventory_transfer = %InventoryTransfer{}
    |> InventoryTransfer.changeset(attrs)
    |> validate_record_existing(InventoryLocation, :from_location_id, prefix, "location does not exist")
    |> validate_record_existing(InventoryLocation, :to_location_id, prefix, "location does not exist")
    |> validate_record_existing(Item, :item_id, prefix, "Item does not exist")
    |> validate_from_location_id(prefix)
    # Repo.insert(prefix: prefix)
    multi = Multi.new()
    |> Multi.insert(:inventory_transfer, inventory_transfer, prefix: prefix)
    |> Multi.run(:inventory_stock, fn repo, %{inventory_transfer: inventory_transfer} ->
      inventory_stock = repo.get_by(InventoryStock, [inventory_location_id: inventory_transfer.from_location_id, item_id: inventory_transfer.item_id], prefix: prefix)
      case inventory_stock do
        nil ->
          InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transfer.from_location_id,
            "item_id" => inventory_transfer.item_id, "quantity" => inventory_transfer.quantity})
          |> InventoryStock.changeset(attrs)
          |> Repo.insert(prefix: prefix)
        inventory_stock ->
          repo.update(change(inventory_stock, quantity: inventory_stock.quantity - inventory_transfer.quantity))
      end
      inventory_stock = repo.get_by(InventoryStock, [inventory_location_id: inventory_transfer.to_location_id, item_id: inventory_transfer.item_id], prefix: prefix)
      case inventory_stock do
        nil ->
          InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transfer.to_location_id,
            "item_id" => inventory_transfer.item_id, "quantity" => inventory_transfer.quantity})
          |> InventoryStock.changeset(attrs)
          |> Repo.insert(prefix: prefix)
        inventory_stock ->
          repo.update(change(inventory_stock, quantity: inventory_stock.quantity + inventory_transfer.quantity))
      end
    end)

    case Repo.transaction(multi) do
      {:ok, %{inventory_transfer: inventory_transfer, inventory_stock: _inventory_stock}} ->
        {:ok, inventory_transfer}

      {:error, :inventory_transfer, inventory_transfer_changeset, _} ->
        {:error, inventory_transfer_changeset}

    end
  end

  def update_stock_after_inventory_transfer(inventory_stock, inventory_transfer, prefix) do
    case inventory_stock do
      nil ->
        InventoryStock.changeset(%InventoryStock{}, %{"inventory_location_id" => inventory_transfer.to_location_id,
          "item_id" => inventory_transfer.item_id, "quantity" => inventory_transfer.quantity})
        |> Repo.insert(prefix: prefix)
      inventory_stock ->
        Repo.update(change(inventory_stock, quantity: inventory_stock.quantity + inventory_transfer.quantity))
    end
  end

  def validate_record_existing(cs, query, key, prefix, error_message) do
    required_id = get_field(cs, key, nil)
    case Repo.get(query, required_id, prefix: prefix) do
      nil ->
        add_error(cs, key, error_message)
      _ ->
        cs
    end
  end

  def validate_from_location_id(cs, prefix) do
    from_location_id = get_field(cs, :from_location_id, nil)
    item_id = get_field(cs, :item_id, nil)
    quantity = get_field(cs, :quantity, nil)
    inventory_stock = Repo.get_by(InventoryStock, [inventory_location_id: from_location_id, item_id: item_id], prefix: prefix)
    case inventory_stock do
      nil ->
        add_error(cs, :item_id, "Specified Item does not exist in given location")

      inventory_stock ->
        if inventory_stock.quantity < quantity do
          add_error(cs, :quantity, "Specified Quantity Not available")
        else
          cs
        end
    end
  end




  # def create_inventory_transfer(attrs \\ %{}, prefix) do
  #   %InventoryTransfer{}
  #   |> InventoryTransfer.changeset(attrs)
  #   |> Repo.insert(prefix: prefix)
  # end


  def update_inventory_transfer(%InventoryTransfer{} = inventory_transfer, attrs, prefix) do
    inventory_transfer
    |> InventoryTransfer.update_changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_inventory_transfer(%InventoryTransfer{} = inventory_transfer, prefix) do
    Repo.delete(inventory_transfer, prefix: prefix)
  end

  def change_inventory_transfer(%InventoryTransfer{} = inventory_transfer, attrs \\ %{}) do
    InventoryTransfer.changeset(inventory_transfer, attrs)
  end

  alias Inconn2Service.Inventory.SupplierItem

  def list_supplier_items(prefix) do
    Repo.all(SupplierItem, prefix: prefix) |> Repo.preload([:item, :supplier])
  end

  def get_supplier_for_item(item_id, prefix) do
    SupplierItem
    |> where(item_id: ^item_id)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:item, :supplier])
  end


  def get_supplier_item!(id, prefix), do: Repo.get!(SupplierItem, id, prefix: prefix) |> Repo.preload([:item, :supplier])


  def create_supplier_item(attrs \\ %{}, prefix) do
    result = %SupplierItem{}
              |> SupplierItem.changeset(attrs)
              |> validate_record_existing(Supplier, :supplier_id, prefix, "Supplier does not exist")
              |> validate_record_existing(Item, :item_id, prefix, "Item does not exist")
              |> validate_record_existing(UOM, :price_unit_uom_id, prefix, "UOM does not exist")
              |> Repo.insert(prefix: prefix)


    case result do
      {:ok, supplier_item} ->
        {:ok, supplier_item |> Repo.preload([:item, :supplier])}

      _ ->
        result
    end
  end

  def update_supplier_item(%SupplierItem{} = supplier_item, attrs, prefix) do
    supplier_item
    |> SupplierItem.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_supplier_item(%SupplierItem{} = supplier_item, prefix) do
    Repo.delete(supplier_item, prefix: prefix)
  end

  def change_supplier_item(%SupplierItem{} = supplier_item, attrs \\ %{}) do
    SupplierItem.changeset(supplier_item, attrs)
  end
end

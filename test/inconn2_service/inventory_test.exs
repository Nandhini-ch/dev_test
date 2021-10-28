defmodule Inconn2Service.InventoryTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Inventory

  describe "suppliers" do
    alias Inconn2Service.Inventory.Supplier

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def supplier_fixture(attrs \\ %{}) do
      {:ok, supplier} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_supplier()

      supplier
    end

    test "list_suppliers/0 returns all suppliers" do
      supplier = supplier_fixture()
      assert Inventory.list_suppliers() == [supplier]
    end

    test "get_supplier!/1 returns the supplier with given id" do
      supplier = supplier_fixture()
      assert Inventory.get_supplier!(supplier.id) == supplier
    end

    test "create_supplier/1 with valid data creates a supplier" do
      assert {:ok, %Supplier{} = supplier} = Inventory.create_supplier(@valid_attrs)
      assert supplier.name == "some name"
    end

    test "create_supplier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_supplier(@invalid_attrs)
    end

    test "update_supplier/2 with valid data updates the supplier" do
      supplier = supplier_fixture()
      assert {:ok, %Supplier{} = supplier} = Inventory.update_supplier(supplier, @update_attrs)
      assert supplier.name == "some updated name"
    end

    test "update_supplier/2 with invalid data returns error changeset" do
      supplier = supplier_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_supplier(supplier, @invalid_attrs)
      assert supplier == Inventory.get_supplier!(supplier.id)
    end

    test "delete_supplier/1 deletes the supplier" do
      supplier = supplier_fixture()
      assert {:ok, %Supplier{}} = Inventory.delete_supplier(supplier)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_supplier!(supplier.id) end
    end

    test "change_supplier/1 returns a supplier changeset" do
      supplier = supplier_fixture()
      assert %Ecto.Changeset{} = Inventory.change_supplier(supplier)
    end
  end

  describe "uoms" do
    alias Inconn2Service.Inventory.UOM

    @valid_attrs %{name: "some name", symbol: "some symbol"}
    @update_attrs %{name: "some updated name", symbol: "some updated symbol"}
    @invalid_attrs %{name: nil, symbol: nil}

    def uom_fixture(attrs \\ %{}) do
      {:ok, uom} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_uom()

      uom
    end

    test "list_uoms/0 returns all uoms" do
      uom = uom_fixture()
      assert Inventory.list_uoms() == [uom]
    end

    test "get_uom!/1 returns the uom with given id" do
      uom = uom_fixture()
      assert Inventory.get_uom!(uom.id) == uom
    end

    test "create_uom/1 with valid data creates a uom" do
      assert {:ok, %UOM{} = uom} = Inventory.create_uom(@valid_attrs)
      assert uom.name == "some name"
      assert uom.symbol == "some symbol"
    end

    test "create_uom/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_uom(@invalid_attrs)
    end

    test "update_uom/2 with valid data updates the uom" do
      uom = uom_fixture()
      assert {:ok, %UOM{} = uom} = Inventory.update_uom(uom, @update_attrs)
      assert uom.name == "some updated name"
      assert uom.symbol == "some updated symbol"
    end

    test "update_uom/2 with invalid data returns error changeset" do
      uom = uom_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_uom(uom, @invalid_attrs)
      assert uom == Inventory.get_uom!(uom.id)
    end

    test "delete_uom/1 deletes the uom" do
      uom = uom_fixture()
      assert {:ok, %UOM{}} = Inventory.delete_uom(uom)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_uom!(uom.id) end
    end

    test "change_uom/1 returns a uom changeset" do
      uom = uom_fixture()
      assert %Ecto.Changeset{} = Inventory.change_uom(uom)
    end
  end

  describe "uom_conversions" do
    alias Inconn2Service.Inventory.UomConversion

    @valid_attrs %{from_uom: 42, inverse_factor: 120.5, mult_factor: 120.5, to_uom: 42}
    @update_attrs %{from_uom: 43, inverse_factor: 456.7, mult_factor: 456.7, to_uom: 43}
    @invalid_attrs %{from_uom: nil, inverse_factor: nil, mult_factor: nil, to_uom: nil}

    def uom_conversion_fixture(attrs \\ %{}) do
      {:ok, uom_conversion} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_uom_conversion()

      uom_conversion
    end

    test "list_uom_conversions/0 returns all uom_conversions" do
      uom_conversion = uom_conversion_fixture()
      assert Inventory.list_uom_conversions() == [uom_conversion]
    end

    test "get_uom_conversion!/1 returns the uom_conversion with given id" do
      uom_conversion = uom_conversion_fixture()
      assert Inventory.get_uom_conversion!(uom_conversion.id) == uom_conversion
    end

    test "create_uom_conversion/1 with valid data creates a uom_conversion" do
      assert {:ok, %UomConversion{} = uom_conversion} = Inventory.create_uom_conversion(@valid_attrs)
      assert uom_conversion.from_uom == 42
      assert uom_conversion.inverse_factor == 120.5
      assert uom_conversion.mult_factor == 120.5
      assert uom_conversion.to_uom == 42
    end

    test "create_uom_conversion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_uom_conversion(@invalid_attrs)
    end

    test "update_uom_conversion/2 with valid data updates the uom_conversion" do
      uom_conversion = uom_conversion_fixture()
      assert {:ok, %UomConversion{} = uom_conversion} = Inventory.update_uom_conversion(uom_conversion, @update_attrs)
      assert uom_conversion.from_uom == 43
      assert uom_conversion.inverse_factor == 456.7
      assert uom_conversion.mult_factor == 456.7
      assert uom_conversion.to_uom == 43
    end

    test "update_uom_conversion/2 with invalid data returns error changeset" do
      uom_conversion = uom_conversion_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_uom_conversion(uom_conversion, @invalid_attrs)
      assert uom_conversion == Inventory.get_uom_conversion!(uom_conversion.id)
    end

    test "delete_uom_conversion/1 deletes the uom_conversion" do
      uom_conversion = uom_conversion_fixture()
      assert {:ok, %UomConversion{}} = Inventory.delete_uom_conversion(uom_conversion)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_uom_conversion!(uom_conversion.id) end
    end

    test "change_uom_conversion/1 returns a uom_conversion changeset" do
      uom_conversion = uom_conversion_fixture()
      assert %Ecto.Changeset{} = Inventory.change_uom_conversion(uom_conversion)
    end
  end

  describe "items" do
    alias Inconn2Service.Inventory.Item

    @valid_attrs %{asset_categories_ids: [], consume_unit: "some consume_unit", inventory_unit_id: "some inventory_unit_id", min_order_quantity: 120.5, name: "some name", part_no: "some part_no", purchase_unit_id: "some purchase_unit_id", reorder_quantity: 120.5, type: "some type"}
    @update_attrs %{asset_categories_ids: [], consume_unit: "some updated consume_unit", inventory_unit_id: "some updated inventory_unit_id", min_order_quantity: 456.7, name: "some updated name", part_no: "some updated part_no", purchase_unit_id: "some updated purchase_unit_id", reorder_quantity: 456.7, type: "some updated type"}
    @invalid_attrs %{asset_categories_ids: nil, consume_unit: nil, inventory_unit_id: nil, min_order_quantity: nil, name: nil, part_no: nil, purchase_unit_id: nil, reorder_quantity: nil, type: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Inventory.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Inventory.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Inventory.create_item(@valid_attrs)
      assert item.asset_categories_ids == []
      assert item.consume_unit == "some consume_unit"
      assert item.inventory_unit_id == "some inventory_unit_id"
      assert item.min_order_quantity == 120.5
      assert item.name == "some name"
      assert item.part_no == "some part_no"
      assert item.purchase_unit_id == "some purchase_unit_id"
      assert item.reorder_quantity == 120.5
      assert item.type == "some type"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Inventory.update_item(item, @update_attrs)
      assert item.asset_categories_ids == []
      assert item.consume_unit == "some updated consume_unit"
      assert item.inventory_unit_id == "some updated inventory_unit_id"
      assert item.min_order_quantity == 456.7
      assert item.name == "some updated name"
      assert item.part_no == "some updated part_no"
      assert item.purchase_unit_id == "some updated purchase_unit_id"
      assert item.reorder_quantity == 456.7
      assert item.type == "some updated type"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_item(item, @invalid_attrs)
      assert item == Inventory.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Inventory.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Inventory.change_item(item)
    end
  end

  describe "inventory_locations" do
    alias Inconn2Service.Inventory.InventoryLocation

    @valid_attrs %{description: "some description", name: "some name", site_id: 42, site_location_id: 42}
    @update_attrs %{description: "some updated description", name: "some updated name", site_id: 43, site_location_id: 43}
    @invalid_attrs %{description: nil, name: nil, site_id: nil, site_location_id: nil}

    def inventory_location_fixture(attrs \\ %{}) do
      {:ok, inventory_location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_inventory_location()

      inventory_location
    end

    test "list_inventory_locations/0 returns all inventory_locations" do
      inventory_location = inventory_location_fixture()
      assert Inventory.list_inventory_locations() == [inventory_location]
    end

    test "get_inventory_location!/1 returns the inventory_location with given id" do
      inventory_location = inventory_location_fixture()
      assert Inventory.get_inventory_location!(inventory_location.id) == inventory_location
    end

    test "create_inventory_location/1 with valid data creates a inventory_location" do
      assert {:ok, %InventoryLocation{} = inventory_location} = Inventory.create_inventory_location(@valid_attrs)
      assert inventory_location.description == "some description"
      assert inventory_location.name == "some name"
      assert inventory_location.site_id == 42
      assert inventory_location.site_location_id == 42
    end

    test "create_inventory_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_inventory_location(@invalid_attrs)
    end

    test "update_inventory_location/2 with valid data updates the inventory_location" do
      inventory_location = inventory_location_fixture()
      assert {:ok, %InventoryLocation{} = inventory_location} = Inventory.update_inventory_location(inventory_location, @update_attrs)
      assert inventory_location.description == "some updated description"
      assert inventory_location.name == "some updated name"
      assert inventory_location.site_id == 43
      assert inventory_location.site_location_id == 43
    end

    test "update_inventory_location/2 with invalid data returns error changeset" do
      inventory_location = inventory_location_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_inventory_location(inventory_location, @invalid_attrs)
      assert inventory_location == Inventory.get_inventory_location!(inventory_location.id)
    end

    test "delete_inventory_location/1 deletes the inventory_location" do
      inventory_location = inventory_location_fixture()
      assert {:ok, %InventoryLocation{}} = Inventory.delete_inventory_location(inventory_location)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_inventory_location!(inventory_location.id) end
    end

    test "change_inventory_location/1 returns a inventory_location changeset" do
      inventory_location = inventory_location_fixture()
      assert %Ecto.Changeset{} = Inventory.change_inventory_location(inventory_location)
    end
  end

  describe "inventory_stocks" do
    alias Inconn2Service.Inventory.InventoryStock

    @valid_attrs %{inventory_location_id: 42, item_id: 42, quantity: 120.5}
    @update_attrs %{inventory_location_id: 43, item_id: 43, quantity: 456.7}
    @invalid_attrs %{inventory_location_id: nil, item_id: nil, quantity: nil}

    def inventory_stock_fixture(attrs \\ %{}) do
      {:ok, inventory_stock} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_inventory_stock()

      inventory_stock
    end

    test "list_inventory_stocks/0 returns all inventory_stocks" do
      inventory_stock = inventory_stock_fixture()
      assert Inventory.list_inventory_stocks() == [inventory_stock]
    end

    test "get_inventory_stock!/1 returns the inventory_stock with given id" do
      inventory_stock = inventory_stock_fixture()
      assert Inventory.get_inventory_stock!(inventory_stock.id) == inventory_stock
    end

    test "create_inventory_stock/1 with valid data creates a inventory_stock" do
      assert {:ok, %InventoryStock{} = inventory_stock} = Inventory.create_inventory_stock(@valid_attrs)
      assert inventory_stock.inventory_location_id == 42
      assert inventory_stock.item_id == 42
      assert inventory_stock.quantity == 120.5
    end

    test "create_inventory_stock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_inventory_stock(@invalid_attrs)
    end

    test "update_inventory_stock/2 with valid data updates the inventory_stock" do
      inventory_stock = inventory_stock_fixture()
      assert {:ok, %InventoryStock{} = inventory_stock} = Inventory.update_inventory_stock(inventory_stock, @update_attrs)
      assert inventory_stock.inventory_location_id == 43
      assert inventory_stock.item_id == 43
      assert inventory_stock.quantity == 456.7
    end

    test "update_inventory_stock/2 with invalid data returns error changeset" do
      inventory_stock = inventory_stock_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_inventory_stock(inventory_stock, @invalid_attrs)
      assert inventory_stock == Inventory.get_inventory_stock!(inventory_stock.id)
    end

    test "delete_inventory_stock/1 deletes the inventory_stock" do
      inventory_stock = inventory_stock_fixture()
      assert {:ok, %InventoryStock{}} = Inventory.delete_inventory_stock(inventory_stock)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_inventory_stock!(inventory_stock.id) end
    end

    test "change_inventory_stock/1 returns a inventory_stock changeset" do
      inventory_stock = inventory_stock_fixture()
      assert %Ecto.Changeset{} = Inventory.change_inventory_stock(inventory_stock)
    end
  end

  describe "inventory_transactions" do
    alias Inconn2Service.Inventory.InventoryTransaction

    @valid_attrs %{inventory_location_id: 42, item_id: 42, price: 120.5, quantity: 120.5, reference: "some reference", supplier_id: 42, transaction_type: "some transaction_type", uom_id: 42, workorder_id: 42}
    @update_attrs %{inventory_location_id: 43, item_id: 43, price: 456.7, quantity: 456.7, reference: "some updated reference", supplier_id: 43, transaction_type: "some updated transaction_type", uom_id: 43, workorder_id: 43}
    @invalid_attrs %{inventory_location_id: nil, item_id: nil, price: nil, quantity: nil, reference: nil, supplier_id: nil, transaction_type: nil, uom_id: nil, workorder_id: nil}

    def inventory_transaction_fixture(attrs \\ %{}) do
      {:ok, inventory_transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_inventory_transaction()

      inventory_transaction
    end

    test "list_inventory_transactions/0 returns all inventory_transactions" do
      inventory_transaction = inventory_transaction_fixture()
      assert Inventory.list_inventory_transactions() == [inventory_transaction]
    end

    test "get_inventory_transaction!/1 returns the inventory_transaction with given id" do
      inventory_transaction = inventory_transaction_fixture()
      assert Inventory.get_inventory_transaction!(inventory_transaction.id) == inventory_transaction
    end

    test "create_inventory_transaction/1 with valid data creates a inventory_transaction" do
      assert {:ok, %InventoryTransaction{} = inventory_transaction} = Inventory.create_inventory_transaction(@valid_attrs)
      assert inventory_transaction.inventory_location_id == 42
      assert inventory_transaction.item_id == 42
      assert inventory_transaction.price == 120.5
      assert inventory_transaction.quantity == 120.5
      assert inventory_transaction.reference == "some reference"
      assert inventory_transaction.supplier_id == 42
      assert inventory_transaction.transaction_type == "some transaction_type"
      assert inventory_transaction.uom_id == 42
      assert inventory_transaction.workorder_id == 42
    end

    test "create_inventory_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_inventory_transaction(@invalid_attrs)
    end

    test "update_inventory_transaction/2 with valid data updates the inventory_transaction" do
      inventory_transaction = inventory_transaction_fixture()
      assert {:ok, %InventoryTransaction{} = inventory_transaction} = Inventory.update_inventory_transaction(inventory_transaction, @update_attrs)
      assert inventory_transaction.inventory_location_id == 43
      assert inventory_transaction.item_id == 43
      assert inventory_transaction.price == 456.7
      assert inventory_transaction.quantity == 456.7
      assert inventory_transaction.reference == "some updated reference"
      assert inventory_transaction.supplier_id == 43
      assert inventory_transaction.transaction_type == "some updated transaction_type"
      assert inventory_transaction.uom_id == 43
      assert inventory_transaction.workorder_id == 43
    end

    test "update_inventory_transaction/2 with invalid data returns error changeset" do
      inventory_transaction = inventory_transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_inventory_transaction(inventory_transaction, @invalid_attrs)
      assert inventory_transaction == Inventory.get_inventory_transaction!(inventory_transaction.id)
    end

    test "delete_inventory_transaction/1 deletes the inventory_transaction" do
      inventory_transaction = inventory_transaction_fixture()
      assert {:ok, %InventoryTransaction{}} = Inventory.delete_inventory_transaction(inventory_transaction)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_inventory_transaction!(inventory_transaction.id) end
    end

    test "change_inventory_transaction/1 returns a inventory_transaction changeset" do
      inventory_transaction = inventory_transaction_fixture()
      assert %Ecto.Changeset{} = Inventory.change_inventory_transaction(inventory_transaction)
    end
  end

  describe "inventory_transfers" do
    alias Inconn2Service.Inventory.InventoryTransfer

    @valid_attrs %{from_location_id: 42, quantity: 42, reference: "some reference", to_location_id: 42, uom_id: 42}
    @update_attrs %{from_location_id: 43, quantity: 43, reference: "some updated reference", to_location_id: 43, uom_id: 43}
    @invalid_attrs %{from_location_id: nil, quantity: nil, reference: nil, to_location_id: nil, uom_id: nil}

    def inventory_transfer_fixture(attrs \\ %{}) do
      {:ok, inventory_transfer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_inventory_transfer()

      inventory_transfer
    end

    test "list_inventory_transfers/0 returns all inventory_transfers" do
      inventory_transfer = inventory_transfer_fixture()
      assert Inventory.list_inventory_transfers() == [inventory_transfer]
    end

    test "get_inventory_transfer!/1 returns the inventory_transfer with given id" do
      inventory_transfer = inventory_transfer_fixture()
      assert Inventory.get_inventory_transfer!(inventory_transfer.id) == inventory_transfer
    end

    test "create_inventory_transfer/1 with valid data creates a inventory_transfer" do
      assert {:ok, %InventoryTransfer{} = inventory_transfer} = Inventory.create_inventory_transfer(@valid_attrs)
      assert inventory_transfer.from_location_id == 42
      assert inventory_transfer.quantity == 42
      assert inventory_transfer.reference == "some reference"
      assert inventory_transfer.to_location_id == 42
      assert inventory_transfer.uom_id == 42
    end

    test "create_inventory_transfer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_inventory_transfer(@invalid_attrs)
    end

    test "update_inventory_transfer/2 with valid data updates the inventory_transfer" do
      inventory_transfer = inventory_transfer_fixture()
      assert {:ok, %InventoryTransfer{} = inventory_transfer} = Inventory.update_inventory_transfer(inventory_transfer, @update_attrs)
      assert inventory_transfer.from_location_id == 43
      assert inventory_transfer.quantity == 43
      assert inventory_transfer.reference == "some updated reference"
      assert inventory_transfer.to_location_id == 43
      assert inventory_transfer.uom_id == 43
    end

    test "update_inventory_transfer/2 with invalid data returns error changeset" do
      inventory_transfer = inventory_transfer_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_inventory_transfer(inventory_transfer, @invalid_attrs)
      assert inventory_transfer == Inventory.get_inventory_transfer!(inventory_transfer.id)
    end

    test "delete_inventory_transfer/1 deletes the inventory_transfer" do
      inventory_transfer = inventory_transfer_fixture()
      assert {:ok, %InventoryTransfer{}} = Inventory.delete_inventory_transfer(inventory_transfer)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_inventory_transfer!(inventory_transfer.id) end
    end

    test "change_inventory_transfer/1 returns a inventory_transfer changeset" do
      inventory_transfer = inventory_transfer_fixture()
      assert %Ecto.Changeset{} = Inventory.change_inventory_transfer(inventory_transfer)
    end
  end

  describe "supplier_items" do
    alias Inconn2Service.Inventory.SupplierItem

    @valid_attrs %{item_id: 42, price: 120.5, price_unit_uom_id: 42, supplier_id: 42, supplier_part_no: "some supplier_part_no"}
    @update_attrs %{item_id: 43, price: 456.7, price_unit_uom_id: 43, supplier_id: 43, supplier_part_no: "some updated supplier_part_no"}
    @invalid_attrs %{item_id: nil, price: nil, price_unit_uom_id: nil, supplier_id: nil, supplier_part_no: nil}

    def supplier_item_fixture(attrs \\ %{}) do
      {:ok, supplier_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_supplier_item()

      supplier_item
    end

    test "list_supplier_items/0 returns all supplier_items" do
      supplier_item = supplier_item_fixture()
      assert Inventory.list_supplier_items() == [supplier_item]
    end

    test "get_supplier_item!/1 returns the supplier_item with given id" do
      supplier_item = supplier_item_fixture()
      assert Inventory.get_supplier_item!(supplier_item.id) == supplier_item
    end

    test "create_supplier_item/1 with valid data creates a supplier_item" do
      assert {:ok, %SupplierItem{} = supplier_item} = Inventory.create_supplier_item(@valid_attrs)
      assert supplier_item.item_id == 42
      assert supplier_item.price == 120.5
      assert supplier_item.price_unit_uom_id == 42
      assert supplier_item.supplier_id == 42
      assert supplier_item.supplier_part_no == "some supplier_part_no"
    end

    test "create_supplier_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_supplier_item(@invalid_attrs)
    end

    test "update_supplier_item/2 with valid data updates the supplier_item" do
      supplier_item = supplier_item_fixture()
      assert {:ok, %SupplierItem{} = supplier_item} = Inventory.update_supplier_item(supplier_item, @update_attrs)
      assert supplier_item.item_id == 43
      assert supplier_item.price == 456.7
      assert supplier_item.price_unit_uom_id == 43
      assert supplier_item.supplier_id == 43
      assert supplier_item.supplier_part_no == "some updated supplier_part_no"
    end

    test "update_supplier_item/2 with invalid data returns error changeset" do
      supplier_item = supplier_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_supplier_item(supplier_item, @invalid_attrs)
      assert supplier_item == Inventory.get_supplier_item!(supplier_item.id)
    end

    test "delete_supplier_item/1 deletes the supplier_item" do
      supplier_item = supplier_item_fixture()
      assert {:ok, %SupplierItem{}} = Inventory.delete_supplier_item(supplier_item)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_supplier_item!(supplier_item.id) end
    end

    test "change_supplier_item/1 returns a supplier_item changeset" do
      supplier_item = supplier_item_fixture()
      assert %Ecto.Changeset{} = Inventory.change_supplier_item(supplier_item)
    end
  end
end

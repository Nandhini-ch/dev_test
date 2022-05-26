defmodule Inconn2Service.InventoryManagementTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.InventoryManagement

  describe "uom_categories" do
    alias Inconn2Service.InventoryManagement.UomCategory

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def uom_category_fixture(attrs \\ %{}) do
      {:ok, uom_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InventoryManagement.create_uom_category()

      uom_category
    end

    test "list_uom_categories/0 returns all uom_categories" do
      uom_category = uom_category_fixture()
      assert InventoryManagement.list_uom_categories() == [uom_category]
    end

    test "get_uom_category!/1 returns the uom_category with given id" do
      uom_category = uom_category_fixture()
      assert InventoryManagement.get_uom_category!(uom_category.id) == uom_category
    end

    test "create_uom_category/1 with valid data creates a uom_category" do
      assert {:ok, %UomCategory{} = uom_category} = InventoryManagement.create_uom_category(@valid_attrs)
      assert uom_category.description == "some description"
      assert uom_category.name == "some name"
    end

    test "create_uom_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.create_uom_category(@invalid_attrs)
    end

    test "update_uom_category/2 with valid data updates the uom_category" do
      uom_category = uom_category_fixture()
      assert {:ok, %UomCategory{} = uom_category} = InventoryManagement.update_uom_category(uom_category, @update_attrs)
      assert uom_category.description == "some updated description"
      assert uom_category.name == "some updated name"
    end

    test "update_uom_category/2 with invalid data returns error changeset" do
      uom_category = uom_category_fixture()
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.update_uom_category(uom_category, @invalid_attrs)
      assert uom_category == InventoryManagement.get_uom_category!(uom_category.id)
    end

    test "delete_uom_category/1 deletes the uom_category" do
      uom_category = uom_category_fixture()
      assert {:ok, %UomCategory{}} = InventoryManagement.delete_uom_category(uom_category)
      assert_raise Ecto.NoResultsError, fn -> InventoryManagement.get_uom_category!(uom_category.id) end
    end

    test "change_uom_category/1 returns a uom_category changeset" do
      uom_category = uom_category_fixture()
      assert %Ecto.Changeset{} = InventoryManagement.change_uom_category(uom_category)
    end
  end

  describe "unit_of_measurements" do
    alias Inconn2Service.InventoryManagement.UnitOfMeasurement

    @valid_attrs %{name: "some name", unit: "some unit"}
    @update_attrs %{name: "some updated name", unit: "some updated unit"}
    @invalid_attrs %{name: nil, unit: nil}

    def unit_of_measurement_fixture(attrs \\ %{}) do
      {:ok, unit_of_measurement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InventoryManagement.create_unit_of_measurement()

      unit_of_measurement
    end

    test "list_unit_of_measurements/0 returns all unit_of_measurements" do
      unit_of_measurement = unit_of_measurement_fixture()
      assert InventoryManagement.list_unit_of_measurements() == [unit_of_measurement]
    end

    test "get_unit_of_measurement!/1 returns the unit_of_measurement with given id" do
      unit_of_measurement = unit_of_measurement_fixture()
      assert InventoryManagement.get_unit_of_measurement!(unit_of_measurement.id) == unit_of_measurement
    end

    test "create_unit_of_measurement/1 with valid data creates a unit_of_measurement" do
      assert {:ok, %UnitOfMeasurement{} = unit_of_measurement} = InventoryManagement.create_unit_of_measurement(@valid_attrs)
      assert unit_of_measurement.name == "some name"
      assert unit_of_measurement.unit == "some unit"
    end

    test "create_unit_of_measurement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.create_unit_of_measurement(@invalid_attrs)
    end

    test "update_unit_of_measurement/2 with valid data updates the unit_of_measurement" do
      unit_of_measurement = unit_of_measurement_fixture()
      assert {:ok, %UnitOfMeasurement{} = unit_of_measurement} = InventoryManagement.update_unit_of_measurement(unit_of_measurement, @update_attrs)
      assert unit_of_measurement.name == "some updated name"
      assert unit_of_measurement.unit == "some updated unit"
    end

    test "update_unit_of_measurement/2 with invalid data returns error changeset" do
      unit_of_measurement = unit_of_measurement_fixture()
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.update_unit_of_measurement(unit_of_measurement, @invalid_attrs)
      assert unit_of_measurement == InventoryManagement.get_unit_of_measurement!(unit_of_measurement.id)
    end

    test "delete_unit_of_measurement/1 deletes the unit_of_measurement" do
      unit_of_measurement = unit_of_measurement_fixture()
      assert {:ok, %UnitOfMeasurement{}} = InventoryManagement.delete_unit_of_measurement(unit_of_measurement)
      assert_raise Ecto.NoResultsError, fn -> InventoryManagement.get_unit_of_measurement!(unit_of_measurement.id) end
    end

    test "change_unit_of_measurement/1 returns a unit_of_measurement changeset" do
      unit_of_measurement = unit_of_measurement_fixture()
      assert %Ecto.Changeset{} = InventoryManagement.change_unit_of_measurement(unit_of_measurement)
    end
  end

  describe "stores" do
    alias Inconn2Service.InventoryManagement.Store

    @valid_attrs %{aisle_count: 42, aisle_notation: "some aisle_notation", bin_count: 42, bin_notation: "some bin_notation", description: "some description", location_id: 42, name: "some name", row_count: 42, row_notation: "some row_notation"}
    @update_attrs %{aisle_count: 43, aisle_notation: "some updated aisle_notation", bin_count: 43, bin_notation: "some updated bin_notation", description: "some updated description", location_id: 43, name: "some updated name", row_count: 43, row_notation: "some updated row_notation"}
    @invalid_attrs %{aisle_count: nil, aisle_notation: nil, bin_count: nil, bin_notation: nil, description: nil, location_id: nil, name: nil, row_count: nil, row_notation: nil}

    def store_fixture(attrs \\ %{}) do
      {:ok, store} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InventoryManagement.create_store()

      store
    end

    test "list_stores/0 returns all stores" do
      store = store_fixture()
      assert InventoryManagement.list_stores() == [store]
    end

    test "get_store!/1 returns the store with given id" do
      store = store_fixture()
      assert InventoryManagement.get_store!(store.id) == store
    end

    test "create_store/1 with valid data creates a store" do
      assert {:ok, %Store{} = store} = InventoryManagement.create_store(@valid_attrs)
      assert store.aisle_count == 42
      assert store.aisle_notation == "some aisle_notation"
      assert store.bin_count == 42
      assert store.bin_notation == "some bin_notation"
      assert store.description == "some description"
      assert store.location_id == 42
      assert store.name == "some name"
      assert store.row_count == 42
      assert store.row_notation == "some row_notation"
    end

    test "create_store/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.create_store(@invalid_attrs)
    end

    test "update_store/2 with valid data updates the store" do
      store = store_fixture()
      assert {:ok, %Store{} = store} = InventoryManagement.update_store(store, @update_attrs)
      assert store.aisle_count == 43
      assert store.aisle_notation == "some updated aisle_notation"
      assert store.bin_count == 43
      assert store.bin_notation == "some updated bin_notation"
      assert store.description == "some updated description"
      assert store.location_id == 43
      assert store.name == "some updated name"
      assert store.row_count == 43
      assert store.row_notation == "some updated row_notation"
    end

    test "update_store/2 with invalid data returns error changeset" do
      store = store_fixture()
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.update_store(store, @invalid_attrs)
      assert store == InventoryManagement.get_store!(store.id)
    end

    test "delete_store/1 deletes the store" do
      store = store_fixture()
      assert {:ok, %Store{}} = InventoryManagement.delete_store(store)
      assert_raise Ecto.NoResultsError, fn -> InventoryManagement.get_store!(store.id) end
    end

    test "change_store/1 returns a store changeset" do
      store = store_fixture()
      assert %Ecto.Changeset{} = InventoryManagement.change_store(store)
    end
  end

  describe "inventory_suppliers" do
    alias Inconn2Service.InventoryManagement.InventorySupplier

    @valid_attrs %{business_type: "some business_type", contact_no: "some contact_no", contact_person: "some contact_person", description: "some description", escalation1_contact_name: "some escalation1_contact_name", escalation1_contact_no: "some escalation1_contact_no", escalation2_contact_name: "some escalation2_contact_name", escalation2_contact_no: "some escalation2_contact_no", gst_no: "some gst_no", name: "some name", reference_no: "some reference_no", website: "some website"}
    @update_attrs %{business_type: "some updated business_type", contact_no: "some updated contact_no", contact_person: "some updated contact_person", description: "some updated description", escalation1_contact_name: "some updated escalation1_contact_name", escalation1_contact_no: "some updated escalation1_contact_no", escalation2_contact_name: "some updated escalation2_contact_name", escalation2_contact_no: "some updated escalation2_contact_no", gst_no: "some updated gst_no", name: "some updated name", reference_no: "some updated reference_no", website: "some updated website"}
    @invalid_attrs %{business_type: nil, contact_no: nil, contact_person: nil, description: nil, escalation1_contact_name: nil, escalation1_contact_no: nil, escalation2_contact_name: nil, escalation2_contact_no: nil, gst_no: nil, name: nil, reference_no: nil, website: nil}

    def inventory_supplier_fixture(attrs \\ %{}) do
      {:ok, inventory_supplier} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InventoryManagement.create_inventory_supplier()

      inventory_supplier
    end

    test "list_inventory_suppliers/0 returns all inventory_suppliers" do
      inventory_supplier = inventory_supplier_fixture()
      assert InventoryManagement.list_inventory_suppliers() == [inventory_supplier]
    end

    test "get_inventory_supplier!/1 returns the inventory_supplier with given id" do
      inventory_supplier = inventory_supplier_fixture()
      assert InventoryManagement.get_inventory_supplier!(inventory_supplier.id) == inventory_supplier
    end

    test "create_inventory_supplier/1 with valid data creates a inventory_supplier" do
      assert {:ok, %InventorySupplier{} = inventory_supplier} = InventoryManagement.create_inventory_supplier(@valid_attrs)
      assert inventory_supplier.business_type == "some business_type"
      assert inventory_supplier.contact_no == "some contact_no"
      assert inventory_supplier.contact_person == "some contact_person"
      assert inventory_supplier.description == "some description"
      assert inventory_supplier.escalation1_contact_name == "some escalation1_contact_name"
      assert inventory_supplier.escalation1_contact_no == "some escalation1_contact_no"
      assert inventory_supplier.escalation2_contact_name == "some escalation2_contact_name"
      assert inventory_supplier.escalation2_contact_no == "some escalation2_contact_no"
      assert inventory_supplier.gst_no == "some gst_no"
      assert inventory_supplier.name == "some name"
      assert inventory_supplier.reference_no == "some reference_no"
      assert inventory_supplier.website == "some website"
    end

    test "create_inventory_supplier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.create_inventory_supplier(@invalid_attrs)
    end

    test "update_inventory_supplier/2 with valid data updates the inventory_supplier" do
      inventory_supplier = inventory_supplier_fixture()
      assert {:ok, %InventorySupplier{} = inventory_supplier} = InventoryManagement.update_inventory_supplier(inventory_supplier, @update_attrs)
      assert inventory_supplier.business_type == "some updated business_type"
      assert inventory_supplier.contact_no == "some updated contact_no"
      assert inventory_supplier.contact_person == "some updated contact_person"
      assert inventory_supplier.description == "some updated description"
      assert inventory_supplier.escalation1_contact_name == "some updated escalation1_contact_name"
      assert inventory_supplier.escalation1_contact_no == "some updated escalation1_contact_no"
      assert inventory_supplier.escalation2_contact_name == "some updated escalation2_contact_name"
      assert inventory_supplier.escalation2_contact_no == "some updated escalation2_contact_no"
      assert inventory_supplier.gst_no == "some updated gst_no"
      assert inventory_supplier.name == "some updated name"
      assert inventory_supplier.reference_no == "some updated reference_no"
      assert inventory_supplier.website == "some updated website"
    end

    test "update_inventory_supplier/2 with invalid data returns error changeset" do
      inventory_supplier = inventory_supplier_fixture()
      assert {:error, %Ecto.Changeset{}} = InventoryManagement.update_inventory_supplier(inventory_supplier, @invalid_attrs)
      assert inventory_supplier == InventoryManagement.get_inventory_supplier!(inventory_supplier.id)
    end

    test "delete_inventory_supplier/1 deletes the inventory_supplier" do
      inventory_supplier = inventory_supplier_fixture()
      assert {:ok, %InventorySupplier{}} = InventoryManagement.delete_inventory_supplier(inventory_supplier)
      assert_raise Ecto.NoResultsError, fn -> InventoryManagement.get_inventory_supplier!(inventory_supplier.id) end
    end

    test "change_inventory_supplier/1 returns a inventory_supplier changeset" do
      inventory_supplier = inventory_supplier_fixture()
      assert %Ecto.Changeset{} = InventoryManagement.change_inventory_supplier(inventory_supplier)
    end
  end
end

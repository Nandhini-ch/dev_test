alias Inconn2Service.InventoryManagement

prefix = "inc_bata"

{:ok, uom_category} =
  InventoryManagement.create_uom_category(
    %{
      "name" => "Weights",
      "description" => "Category that denotes weight"
    },
    prefix
  )

{:ok, uom1} =
  InventoryManagement.create_unit_of_measurement(
    %{
      "name" => "Gram",
      "unit" => "g",
      "uom_category_id" => uom_category.id
    },
    prefix
  )

{:ok, uom2} =
  InventoryManagement.create_unit_of_measurement(
    %{
      "name" => "Kilogram",
      "unit" => "kg",
      "uom_category_id" => uom_category.id
    },
    prefix
  )

{:ok, conversion} =
  InventoryManagement.create_conversion(
    %{
      "from_unit_of_measurement_id" => uom2.id,
      "to_unit_of_measurement_id" => uom1.id,
      "uom_category_id" => uom_category.id,
      "multiplication_factor" => 1000
    },
    prefix
  )

{:ok, item1} =
  InventoryManagement.create_inventory_item(
    %{
      "name" => "Cement",
      "part_no" => "123",
      "item_type" => "Tool",
      "minimum_stock_level" => 10,
      "remarks" => "Cements used to build buildings",
      "uom_category_id" => uom_category.id,
      "unit_price" => 440.0,
      "is_approval_required" => false,
      "asset_category_ids" => [1],
      "consume_unit_of_measurement_id" => uom2.id,
      "purchase_unit_of_measurement_id" => uom2.id,
      "inventory_unit_of_measurement_id" => uom1.id,
    },
    prefix
  )

{:ok, store1} =
  InventoryManagement.create_store(
    %{
      "name" => "Inventory Store 1",
      "person_or_location_based" => "L",
      "is_layout_configuration_required" => false,
      "site_id" => 1,
      "location_id" => 1
    },
    prefix
  )

  {:ok, store2} =
    InventoryManagement.create_store(
      %{
        "name" => "Inventory Store 1",
        "person_or_location_based" => "L",
        "is_layout_configuration_required" => true,
        "site_id" => 1,
        "location_id" => 1,
        "aisle_count" => 10,
        "aisle_notation" => "U",
        "row_count" => 10,
        "row_notation" => "L",
        "bin_count" => 10,
        "bin_notation" => "N"
      },
      prefix
    )

{:ok, inventory_supplier} =
  InventoryManagement.create_inventory_supplier(
    %{
      "name" => "Sudhan Tools",
      "business_type" => "Tools Manufacturer",
      "contact_person" =>  "Mr. Harisudhan Ravi",
      "contact_no" => "1234567890",
      "escalation1_contact_name" => "Mr. Poochi",
      "escalation1_contact_no" => "1234567890"
    },
    prefix
  )

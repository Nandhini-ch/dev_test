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
      "from_unit_of_measurement_id" => uom1.id,
      "to_unit_of_measurement_id" => uom2.id,
      "uom_category_id" => uom_category.id,
      "multiplication_factor" => 1000
    },
    prefix
  )

alias Inconn2Service.Inventory

supplier1 = %{
	"name" => "Supplier 1",
	"description" => "Supplier for bata",
	"nature_of_business" => "Supplying Spare Parts",
	"registration_no" => "123412",
	"gst_no" => "12345",
	"contact" => %{
		"first_name" => "John",
		"last_name" => "Doe",
		"designation" => "Manager",
		"mobile" => "+917639883938",
		"land_line" => "+91-40-908764",
		"email" => "john@bata.co.in"
	}
}

supplier2 = %{
	"name" => "Supplier 2",
	"description" => "Supplier for bata",
	"nature_of_business" => "Supplying Consumables",
	"registration_no" => "1234",
	"gst_no" => "12345768",
	"contact" => %{
		"first_name" => "John",
		"last_name" => "Bunyan",
		"designation" => "Manager",
		"mobile" => "+917639883938",
		"land_line" => "+91-40-908764",
		"email" => "john@bata.co.in"
	}
}

{:ok, supplier1} = Inventory.create_supplier(supplier1, "inc_bata")
{:ok, supplier2} = Inventory.create_supplier(supplier2, "inc_bata")


uom1 = %{
	"name" => "Gram",
	"symbol" => "g",
	"uom_type" => "physical"
}

uom2 = %{
	"name" => "Kilo Gram",
	"symbol" => "kg",
	"uom_type" => "physical"
}

uom3 = %{
	"name" => "Numerables",
	"symbol" => "no",
	"uom_type" => "physical"
}

{:ok, unit1} = Inventory.create_uom(uom1, "inc_bata")
{:ok, unit2} = Inventory.create_uom(uom2, "inc_bata")
{:ok, unit3} = Inventory.create_uom(uom3, "inc_bata")

uom_conversion = %{
	"from_uom_id" => unit2.id,
	"to_uom_id" => unit1.id,
	"mult_factor" => 1000
}

{:ok, conversion} = Inventory.create_uom_conversion(uom_conversion, "inc_bata")

item1 = %{
	"part_no" => "2e43",
	"name" => "A Inventory Item",
	"type" => "consumables",
	"purchase_unit_uom_id" => unit2.id,
	"inventory_unit_uom_id" => unit1.id,
	"consume_unit_uom_id" => unit2.id,
	"reorder_quantity" => 10,
	"min_order_quantity" => 5,
	"asset_categories_ids" => [1],
	"aisle" => "1",
	"row" => "a",
	"bin" => "1"
}

item2 = %{
	"part_no" => "2e44",
	"name" => "A Second Inventory Item",
	"type" => "consumables",
	"purchase_unit_uom_id" => unit2.id,
	"inventory_unit_uom_id" => unit1.id,
	"consume_unit_uom_id" => unit1.id,
	"reorder_quantity" => 10,
	"min_order_quantity" => 5,
	"asset_categories_ids" => [1],
	"aisle" => "1",
	"row" => "a",
	"bin" => "2"
}

item3 = %{
	"part_no" => "2e44",
	"name" => "A Third Inventory Item",
	"type" => "tools",
	"purchase_unit_uom_id" => unit3.id,
	"inventory_unit_uom_id" => unit3.id,
	"consume_unit_uom_id" => unit3.id,
	"reorder_quantity" => 10,
	"min_order_quantity" => 5,
	"asset_categories_ids" => [1],
	"aisle" => "1",
	"row" => "a",
	"bin" => "3"
}

item4 = %{
	"part_no" => "2e44",
	"name" => "A Fourth Inventory Item",
	"type" => "spares",
	"purchase_unit_uom_id" => unit3.id,
	"inventory_unit_uom_id" => unit3.id,
	"consume_unit_uom_id" => unit3.id,
	"reorder_quantity" => 10,
	"min_order_quantity" => 5,
	"asset_categories_ids" => [1],
	"aisle" => "1",
	"row" => "a",
	"bin" => "4"
}

item5 = %{
	"part_no" => "2e44",
	"name" => "A Fifth Inventory Item",
	"type" => "spares",
	"purchase_unit_uom_id" => unit3.id,
	"inventory_unit_uom_id" => unit3.id,
	"consume_unit_uom_id" => unit3.id,
	"reorder_quantity" => 10,
	"min_order_quantity" => 5,
	"asset_categories_ids" => [1],
	"aisle" => "1",
	"row" => "a",
	"bin" => "5"
}

{:ok, item1} = Inventory.create_item(item1, "inc_bata")
{:ok, item2} = Inventory.create_item(item2, "inc_bata")
{:ok, item3} = Inventory.create_item(item3, "inc_bata")
{:ok, item4} = Inventory.create_item(item4, "inc_bata")
{:ok, item5} = Inventory.create_item(item5, "inc_bata")

supplier_item = %{
	"supplier_id" => supplier1.id,
	"item_id" => item1.id,
	"supplier_part_no" => "1234",
	"price" => 10,
	"price_unit_uom_id" => unit2.id
}

{:ok, supplier_item} = Inventory.create_supplier_item(supplier_item, "inc_bata")

inventory_location1 = %{
	"name" => "Location 1",
	"description" => "An inventory Location",
	"site_id" => 1
}

inventory_location2 = %{
	"name" => "Location 2",
	"description" => "Another inventory Location",
	"site_id" => 1
}

{:ok, inventory_location1} = Inventory.create_inventory_location(inventory_location1, "inc_bata")
{:ok, inventory_location2} = Inventory.create_inventory_location(inventory_location2, "inc_bata")


inventory_transaction1 = %{
	"inventory_location_id" => inventory_location1.id,
	"item_id" => item1.id,
	"transaction_type" => "IN",
	"price" => 10,
	"supplier_id" => supplier1.id,
	"reference" =>"test",
	"quantity" => 11,
	"uom_id" => unit2.id,
	"dc_reference" => "1234",
	"dc_date" => "2021-11-27"
}

{:ok, inventory_transaction1} = Inventory.create_inventory_transaction(inventory_transaction1, "inc_bata")

inventory_transaction2 = %{
	"inventory_location_id" => inventory_location1.id,
	"item_id" => item1.id,
	"transaction_type" => "IN",
	"price" => 10,
	"supplier_id" => supplier1.id,
	"reference" =>"test",
	"quantity" => 11,
	"uom_id" => unit2.id,
	"dc_reference" => "1235",
	"dc_date" => "2022-11-27"
}

{:ok, inventory_transaction2} = Inventory.create_inventory_transaction(inventory_transaction2, "inc_bata")


# inventory_transfer = %{
# 	"from_location_id" => inventory_location1.id,
# 	"to_location_id" => inventory_location2.id,
# 	"quantity" => 5,
# 	"uom_id" => unit2.id,
# 	"item_id" => item1.id,
# 	"reference" => "Test"
# }

# {:ok, inventory_transfer} = Inventory.create_inventory_transfer(inventory_transfer, "inc_bata")

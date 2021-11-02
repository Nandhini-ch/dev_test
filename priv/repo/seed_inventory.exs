alias Inconn2Service.Inventory

supplier1 = %{
	"name" => "Supplier 1",
	"description" => "Supplier for bata",
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
	"name" => "Supplier @",
	"description" => "Supplier for bata",
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
	"symbol" => "g"
} 

uom2 = %{
	"name" => "Kilo Gram",
	"symbol" => "kg"
}

{:ok, unit1} = Inventory.create_uom(uom1, "inc_bata")
{:ok, unit2} = Inventory.create_uom(uom2, "inc_bata")

uom_conversion = %{
	"from_uom_id" => 1,
	"to_uom_id" => 2,
	"mult_factor" => 1000
}

{:ok, conversion} = Inventory.create_uom_conversion(uom_conversion, "inc_bata")

item1 = %{
	"part_no" => "2e43",
	"name" => "A Inventory Item",
	"type" => "consumables",
	"purchase_unit_uom_id" => unit2.id,
	"inventory_unit_uom_id" => unit2.id,
	"consume_unit_uom_id" => unit2.id,
	"reorder_quantity" => 10,
	"min_order_quantity" => 5,
	"asset_categories_ids" => [1]
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
	"asset_categories_ids" => [1]
}

{:ok, item1} = Inventory.create_item(item1, "inc_bata")
{:ok, item2} = Inventory.create_item(item2, "inc_bata")

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


inventory_transaction = %{
	"inventory_location_id" => inventory_location1.id,
	"item_id" => item1.id,
	"transaction_type" => "IN",
	"price" => 10,
	"supplier_id" => supplier1.id,
	"reference" =>"test",
	"quantity" => 11,
	"uom_id" => unit2.id
}

{:ok, inventory_transaction} = Inventory.create_inventory_transaction(inventory_transaction, "inc_bata")

inventory_transfer = %{
	"from_location_id" => inventory_location1.id,
	"to_location_id" => inventory_location2.id,
	"quantity" => 5,
	"uom_id" => unit2.id,
	"item_id" => item1.id,
	"reference" => "Test"
}

{:ok, inventory_transfer} = Inventory.create_inventory_transfer(inventory_transfer, "inc_bata")

alias Inconn2Service.Inventory

supplier = %{
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

IO.inspect(Inventory.create_supplier(supplier, "inc_bata"))
alias Inconn2Service.Account

bt = %{"name" => "Shoe Retail"}
{:ok, btrec} = Account.create_business_type(bt)

client = %{
  "company_name" => "Bata Shoe Company",
  "business_type_id" => btrec.id,
  "sub_domain" => "bata",
  "address" => %{
    "address_line1" => "18, First Street",
    "address_line2" => "Anna Nagar",
    "city" => "Chennai",
    "state" => "Tamilnadu",
    "country" => "India",
    "postcode" => "600040"
  },
  "contact" => %{
    "first_name" => "Bala",
    "last_name" => "Chandar",
    "designation" => "Sales Head",
    "land_line" => "+91-44-2457727",
    "mobile" => "+91-9840022485",
    "email" => "balac@bata.co.in"
  }
}

case Account.create_licensee(client) do
  {:ok, lic} -> IO.inspect(lic)
  {:error, cs} -> IO.inspect(cs)
end

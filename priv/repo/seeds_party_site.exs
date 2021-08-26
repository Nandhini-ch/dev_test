alias Inconn2Service.{Account, AssetConfig, WorkOrderConfig}


client2 = %{
  "company_name" => "Addidas Shoe Company",
  "business_type_id" => 1,
  "sub_domain" => "addidas",
  "party_type" => ["AO", "SP"],
  "other_party_type" => "SP",
  "address" => %{
    "address_line1" => "18, third Street",
    "address_line2" => "Gandhi Nagar",
    "city" => "Chennai",
    "state" => "Tamilnadu",
    "country" => "India",
    "postcode" => "600040"
  },
  "contact" => %{
    "first_name" => "HariSudhan",
    "last_name" => "R",
    "designation" => "Teach Lead",
    "land_line" => "+91-44-2457727",
    "mobile" => "+91-9840022485",
    "email" => "HariR@addidas.co.in"
  }
}

IO.inspect(Account.create_licensee(client2))

client3 = %{
  "company_name" => "Nokia Company",
  "business_type_id" => 1,
  "sub_domain" => "nokia",
  "party_type" => ["SP", "SP"],
  "other_party_type" => "SP",
  "address" => %{
    "address_line1" => "120 Ranganathan street",
    "address_line2" => "Ganesh Nagar",
    "city" => "Chennai",
    "state" => "Tamilnadu",
    "country" => "India",
    "postcode" => "600042"
  },
  "contact" => %{
    "first_name" => "xyz",
    "last_name" => "B",
    "designation" => "visionary",
    "land_line" => "+91-44-2457727",
    "mobile" => "+91-9840022485",
    "email" => "xyz@addidas.co.in"
  }
}

IO.inspect(Account.create_licensee(client3))

client4 = %{
  "company_name" => "Starbucks coffee Company",
  "business_type_id" => 1,
  "sub_domain" => "starbucks",
  "party_type" => ["SP", "AO"],
  "other_party_type" => "AO",
  "address" => %{
    "address_line1" => "18, third Street",
    "address_line2" => "Gandhi Nagar",
    "city" => "Chennai",
    "state" => "Tamilnadu",
    "country" => "India",
    "postcode" => "600040"
  },
  "contact" => %{
    "first_name" => "HariSudhan",
    "last_name" => "R",
    "designation" => "Teach Lead",
    "land_line" => "+91-44-2457727",
    "mobile" => "+91-9840022485",
    "email" => "HariR@addidas.co.in"
  }
}

IO.inspect(Account.create_licensee(client4))

site = %{
  "name" => "Mountroad",
  "description" => "Main branch at Mount road",
  "site_code" => "BRCHN_MNTRD",
  "party_id" => 1
}

sc =
  case IO.inspect(AssetConfig.create_site(site, "inc_bata")) do
    {:ok, site_created} -> IO.inspect(site_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

site = %{
  "name" => "GANDHINAGAR",
  "description" => "Main branch at GANDHINAGAR road",
  "site_code" => "BRCHN_MNTRDLTD",
  "party_id" => 1
}

sc =
  case IO.inspect(AssetConfig.create_site(site, "inc_addidas")) do
    {:ok, site_created} -> IO.inspect(site_created)
    {:error, cs} -> IO.inspect(cs)
  end

site = %{
  "name" => "Mountroad",
  "description" => "Main branch at Mount road",
  "site_code" => "BRCHN_MNTRD",
  "party_id" => 1
}

sc =
  case IO.inspect(AssetConfig.create_site(site, "inc_nokia")) do
    {:ok, site_created} -> IO.inspect(site_created)
    cs -> IO.inspect(cs)
  end

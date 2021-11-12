alias Inconn2Service.Common
Common.build_timezone_db()

bt = %{"name" => "Facility Management"}
{:ok, btrec} = Account.create_business_type(bt)

client = %{
  "company_name" => "UPDATER SERVICES (P) Limited",
  "business_type_id" => btrec.id,
  "sub_domain" => "uds",
  "party_type" => "SP",
  "address" => %{
    "address_line1" => "No.2/302/A, UDS Salai",
    "address_line2" => "Off. Old Mahabalipuram Road, Thoraipakkam",
    "city" => "Chennai",
    "state" => "Tamilnadu",
    "country" => "India",
    "postcode" => "600097"
  },
  "contact" => %{
    "first_name" => "Ajithkumar",
    "last_name" => "BS",
    "designation" => "AVP- Digital Transformation",
    #"land_line" => "+91-44-2457727",
    "mobile" => "+91-9061057706",
    "email" => "info@inconn.com"
  }
}

IO.inspect(Account.create_licensee(client))

party = %{
  "company_name" => "Hindustan Coco Cola Beaverages Limited",
  "party_type" => "AO",
  "licensee" => true
}

pc =
  case IO.inspect(AssetConfig.create_party(party, "inc_uds")) do
    {:ok, party_created} -> IO.inspect(party_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

  employee1 = %{
    "employee_id" => "Empid0001",
    "landline_no" => "12345",
    "mobile_no" => "hello123",
    "salary" =>  10000.00,
    "designation" => "Director",
    "email" => "abc@c.com",
    "first_name" => "Rama",
    "last_name" =>  "Janma boomi",
    "has_login_credentials" => true,
    "skills" => [1,2],
    "org_unit_id" =>  1,
    "party_id" => pc.id,
    "role_ids" => [1, 2]
  }
  {:ok, emp_cs1} = Staff.create_employee(employee1, "inc_uds")
  
  employee2 = %{
    "employee_id" => "Empid0002",
    "landline_no" => "123",
    "mobile_no" => "hello123",
    "salary" =>  20000.00,
    "designation" => "Head of School",
    "email" => "blab@c.com",
    "first_name" => "Rebecca",
    "last_name" =>  "Clerkman",
    "has_login_credentials" => true,
    "skills" => [1],
    "org_unit_id" =>  1,
    "party_id" => pc.id,
    "role_ids" => [2]
  }
  
  {:ok, emp_cs2} = Staff.create_employee(employee2,"inc_uds")
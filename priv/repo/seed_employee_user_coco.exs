alias Inconn2Service.Staff

org_ut1 = %{"name" => "Electrical", "party_id" => 1}
org_ut2 = %{"name" => "Mechanical", "party_id" => 1}
org_ut3 = %{"name" => "AHU", "party_id" => 1, "parent_id" => 2}
org_ut4 = %{"name" => "Controllers", "party_id" => 1, "parent_id" => 3}

{:ok, org_ut1c} = Staff.create_org_unit(org_ut1, "inc_uds")
{:ok, org_ut2c} = Staff.create_org_unit(org_ut2, "inc_uds")
{:ok, org_ut3c} = Staff.create_org_unit(org_ut3, "inc_uds")
{:ok, org_ut4c} = Staff.create_org_unit(org_ut4, "inc_uds")


employee1 = %{
  "employee_id" => "Empid0001",
  "landline_no" => "12345",
  "mobile_no" => "080-3349-5830",
  "salary" =>  10000.00,
  "designation" => "Director",
  "email" => "abc@c.com",
  "first_name" => "Rama",
  "last_name" =>  "Janma boomi",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1
}
emp1 =
case (IO.inspect(Staff.create_employee(employee1,"inc_uds"))) do
  {:ok, emp_created} -> IO.inspect(emp_created)
  {:error, cs} -> IO.inspect(cs)
  nil -> IO.puts("null value returned")
end

IO.inspect(emp1)
IO.puts("First employee done $$$$$$$$$$$$$$$$$$$$")

employee2 = %{
  "employee_id" => "Empid0002",
  "landline_no" => "123",
  "mobile_no" => "0805830",
  "salary" =>  20000.00,
  "designation" => "Head of School",
  "email" => "blab@c.com",
  "first_name" => "Rebecca",
  "last_name" =>  "Clerkman",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1
}

emp2 =
  case (IO.inspect(Staff.create_employee(employee2,"inc_uds"))) do
    {:ok, emp_created} -> IO.inspect(emp_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

IO.inspect(emp2)
IO.puts("Second employee done $$$$$$$$$$$$$$$$$$$$")

roles1 = %{
  "code" => "EMP",
  "name" => "Employee"
}

roles2 = %{
  "code" => "MGR",
  "name" => "Manager"
}

roles3 = %{
  "code" => "ADM",
  "name" => "Admin"
}

rc1 =
  case IO.inspect(Staff.create_role(roles1, "inc_uds")) do
    {:ok, role_created} -> IO.inspect(role_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

  IO.inspect(rc1)
IO.puts("Role done $$$$$$$$$$$$$$$$$$$$")

rc2 =
  case IO.inspect(Staff.create_role(roles2, "inc_uds")) do
    {:ok, role_created} -> IO.inspect(role_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

  IO.inspect(rc2)
IO.puts("Role done $$$$$$$$$$$$$$$$$$$$")

rc3 =
  case IO.inspect(Staff.create_role(roles3, "inc_uds")) do
    {:ok, role_created} -> IO.inspect(role_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

  IO.inspect(rc3)
IO.puts("Role done $$$$$$$$$$$$$$$$$$$$")


  user1 = %{
    "password" => "hello123",
    "role_id" => [1,2],
    "username" => "abc@c.com",
    "first_name" => "Rama",
    "last_name" =>  "Janma boomi",
    "has_login_credentials" => true,
    "org_unit_id" =>  1,
    "party_id" => 1
  }

pc =
  case IO.inspect(Staff.create_user(user1, "inc_uds")) do
    {:ok, party_created} -> IO.inspect(party_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

  IO.inspect(pc)
IO.puts("User done $$$$$$$$$$$$$$$$$$$$")

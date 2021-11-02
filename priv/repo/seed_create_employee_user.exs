alias Inconn2Service.{Staff, Assignment}

feat1 = %{"name" => "Create Site", "code" => "CRST", "description" => "Can create site"}
feat2 = %{"name" => "Create Asset", "code" => "CRAS", "description" => "Can create locations and equipment"}
feat3 = %{"name" => "Create Employee", "code" => "CREM", "description" => "Can create employees"}

{:ok, feat1c} = Staff.create_feature(feat1, "inc_bata")
{:ok, feat2c} = Staff.create_feature(feat2, "inc_bata")
{:ok, feat3c} = Staff.create_feature(feat3, "inc_bata")

role1 = %{"name" => "Super Admin", "description" => "Has all access", "features" => ["CRST", "CRAS", "CREM"]}
role2 = %{"name" => "Site Admin", "description" => "Has access to assets", "features" => ["CRAS", "CREM"]}

{:ok, role1c} = Staff.create_role(role1, "inc_bata")
{:ok, role2c} = Staff.create_role(role2, "inc_bata")

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
  "party_id" => 1,
  "role_ids" => [1, 2]
}
{:ok, emp_cs1} = Staff.create_employee(employee1,"inc_bata")

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
  "party_id" => 1,
  "role_ids" => [2]
}

{:ok, emp_cs2} = Staff.create_employee(employee2,"inc_bata")

emp_rst1 = %{
  "employee_id" => 1,
  "site_id" => 1,
  "shift_id" => 1,
  "start_date" => "2021-08-17",
  "end_date" => "2021-08-30"
}
emp_rst2 = %{
  "employee_id" => 2,
  "site_id" => 1,
  "shift_id" => 2,
  "start_date" => "2021-08-20",
  "end_date" => "2021-08-21"
}

 {:ok, emp_rst1c} = Assignment.create_employee_roster(emp_rst1, "inc_bata")
 {:ok, emp_rst2c} = Assignment.create_employee_roster(emp_rst2, "inc_bata")

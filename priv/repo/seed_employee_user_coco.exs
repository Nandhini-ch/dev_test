alias Inconn2Service.Staff

org_ut1 = %{"name" => "House Keeping", "party_id" => 1}

{:ok, org_ut1c} = Staff.create_org_unit(org_ut1, "inc_uds")


feat1 = %{"name" => "Create Site", "code" => "CRST", "description" => "Can create site"}
feat2 = %{"name" => "Create Asset", "code" => "CRAS", "description" => "Can create locations and equipment"}
feat3 = %{"name" => "Create Employee", "code" => "CREM", "description" => "Can create employees"}
feat4 = %{"name" => "Work order creation", "code" => "WOCR", "description" => "Can create workorders"}
feat5 = %{"name" => "Work order execution", "code" => "WOEX", "description" => "Can execute workorders"}

{:ok, feat1c} = Staff.create_feature(feat1, "inc_uds")
{:ok, feat2c} = Staff.create_feature(feat2, "inc_uds")
{:ok, feat3c} = Staff.create_feature(feat3, "inc_uds")
{:ok, feat4c} = Staff.create_feature(feat4, "inc_uds")
{:ok, feat5c} = Staff.create_feature(feat5, "inc_uds")

role1 = %{"name" => "Super Admin", "description" => "Has all access", "features" => ["CRST", "CRAS", "CREM"]}
role2 = %{"name" => "Site Admin", "description" => "Has access to assets", "features" => ["CRAS", "CREM"]}
role3 = %{"name" => "Supervisor", "description" => "Execution of work flows", "features" => ["WOEX"]}

{:ok, role1c} = Staff.create_role(role1, "inc_uds")
{:ok, role2c} = Staff.create_role(role2, "inc_uds")
{:ok, role3c} = Staff.create_role(role3, "inc_uds")

employee1 = %{
  "employee_id" => "Empid0001",
  "mobile_no" => "+91-7305556558",
  "designation" => "Manager - Engineering Services",
  "email" => "arul.nambi@uds.in",
  "first_name" => "Arul Nambi",
  "last_name" =>  "S",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1,
  "username" => "arul.nambi@uds.in",
  "role_id" => [1],
  "password" => "hello123",
  "password_confirmation" => "hello123"
}
{:ok, emp_cs1} = Staff.create_employee(employee1,"inc_uds")

employee2 = %{
  "employee_id" => "Empid0002",
  "mobile_no" => "+91-7373844860",
  "designation" => "Support Engineering",
  "email" => "gokulakrishnan.a@uds.in",
  "first_name" => "Gokulakrishnan",
  "last_name" =>  "Arumugam",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1,
  "username" => "gokulakrishnan.a@uds.in",
  "role_id" => [2],
  "password" => "hello123",
  "password_confirmation" => "hello123"
}

{:ok, emp_cs2} = Staff.create_employee(employee2,"inc_uds")

employee3 = %{
  "employee_id" => "Empid0003",
  "mobile_no" => "+91-9876543210",
  "designation" => "Supervisor",
  "email" => "earnest.p@inconn.com",
  "first_name" => "Earnest Josh",
  "last_name" =>  "Paul",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1,
  "username" => "earnest.p@inconn.com",
  "role_id" => [3],
  "password" => "hello123",
  "password_confirmation" => "hello123"
}

{:ok, emp_cs3} = Staff.create_employee(employee3,"inc_uds")

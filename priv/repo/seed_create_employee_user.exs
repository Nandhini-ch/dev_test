alias Inconn2Service.{Staff, Assignment, Common}

# feat1 = %{"name" => "Create sites", "code" => "CRST", "description" => "Can create site"}
# feat2 = %{"name" => "Create Asset", "code" => "CRAS", "description" => "Can create locations and equipment"}
# feat3 = %{"name" => "Create Employee", "code" => "CREM", "description" => "Can create employees"}
#
# {:ok, feat1c} = Staff.create_feature(feat1, "inc_bata")
# {:ok, feat2c} = Staff.create_feature(feat2, "inc_bata")
# {:ok, feat3c} = Staff.create_feature(feat3, "inc_bata")

role_prof1 = Staff.get_role_profile_by_name!("Admin", "inc_bata") |> Staff.filter_permissions()
role_prof2 = Staff.get_role_profile_by_name!("Manager", "inc_bata") |> Staff.filter_permissions()

role1 = %{"name" => "Admin", "description" => "Has all access", "role_profile_id" => role_prof1.id, "permissions" => role_prof1.permissions}
role2 = %{"name" => "Site Admin", "description" => "Has access to assets", "role_profile_id" => role_prof2.id,  "permissions" => role_prof2.permissions}

{:ok, role1c} = Staff.create_role(role1, "inc_bata")
{:ok, role2c} = Staff.create_role(role2, "inc_bata")

designation = %{
  "name" => "Admin",
  "description" => "designation",
  "active" => true
}
{:ok, designation} = Staff.create_designation(designation, "inc_bata")

employee1 = %{
  "employee_id" => "Empid0001",
  "landline_no" => "12345",
  "mobile_no" => "hello123",
  "salary" =>  10000.00,
  "designation" => "Director",
  "designation_id" => designation.id,
  "email" => "abc@c.com",
  "first_name" => "Rama",
  "last_name" =>  "Janma boomi",
  "has_login_credentials" => true,
  "skills" => [1,2],
  "org_unit_id" =>  1,
  "party_id" => 1,
  "role_id" => 1
}
{:ok, emp_cs1} = Staff.create_employee(employee1,"inc_bata")

employee2 = %{
  "employee_id" => "Empid0002",
  "landline_no" => "123",
  "mobile_no" => "hello123",
  "salary" =>  20000.00,
  "designation" => "Head of School",
  "designation_id" => designation.id,
  "email" => "blab@c.com",
  "first_name" => "Rebecca",
  "last_name" =>  "Clerkman",
  "has_login_credentials" => true,
  "skills" => [1],
  "reports_to" => emp_cs1.id,
  "org_unit_id" =>  1,
  "party_id" => 1,
  "role_id" => 3
}

{:ok, emp_cs2} = Staff.create_employee(employee2,"inc_bata")

employee3 = %{
  "employee_id" => "Empid0003",
  "landline_no" => "123",
  "mobile_no" => "hello123",
  "salary" =>  20000.00,
  "designation" => "Technician",
  "designation_id" => designation.id,
  "email" => "tech@c.com",
  "first_name" => "John",
  "last_name" =>  "Clerkman",
  "has_login_credentials" => false,
  "skills" => [1],
  "reports_to" => emp_cs1.id,
  "org_unit_id" =>  1,
  "party_id" => 1
}

{:ok, emp_cs3} = Staff.create_employee(employee3,"inc_bata")

employee4 = %{
  "employee_id" => "Empid0004",
  "landline_no" => "123",
  "mobile_no" => "hello123",
  "salary" =>  20000.00,
  "designation" => "Head of School",
  "designation_id" => designation.id,
  "email" => "xyz@c.com",
  "first_name" => "Rebecca",
  "last_name" =>  "Clerkman",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  2,
  "reports_to" => emp_cs1.id,
  "party_id" => 2,
  "role_id" => 3
}

{:ok, emp_cs4} = Staff.create_employee(employee4,"inc_bata")

employee5 = %{
  "employee_id" => "Empid0005",
  "landline_no" => "123",
  "mobile_no" => "hello123",
  "salary" =>  20000.00,
  "designation" => "Head of School",
  "designation_id" => designation.id,
  "email" => "qwe@c.com",
  "first_name" => "Rebecca",
  "last_name" =>  "Clerkman",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 2,
  "role_id" => 3
}

{:ok, emp_cs5} = Staff.create_employee(employee5,"inc_bata")

emp_rst1 = %{
  "employee_id" => emp_cs1.id,
  "shift_id" => 1,
  "start_date" => "2021-08-17",
  "end_date" => "2022-08-30"
}
emp_rst2 = %{
  "employee_id" => emp_cs2.id,
  "shift_id" => 1,
  "start_date" => "2021-08-20",
  "end_date" => "2022-08-21"
}
emp_rst3 = %{
  "employee_id" => emp_cs3.id,
  "shift_id" => 1,
  "start_date" => "2021-08-10",
  "end_date" => "2022-08-30"
}
emp_rst4 = %{
  "employee_id" => emp_cs1.id,
  "shift_id" => 1,
  "start_date" => "2021-08-20",
  "end_date" => "2022-08-30"
}
emp_rst5 = %{
  "employee_id" => emp_cs4.id,
  "shift_id" => 1,
  "start_date" => "2021-08-10",
  "end_date" => "2022-08-30"
}
emp_rst6 = %{
  "employee_id" => emp_cs5.id,
  "shift_id" => 1,
  "start_date" => "2021-08-10",
  "end_date" => "2022-08-30"
}

 {:ok, emp_rst1c} = Assignment.create_employee_roster(emp_rst1, "inc_bata")
 {:ok, emp_rst2c} = Assignment.create_employee_roster(emp_rst2, "inc_bata")
 {:ok, emp_rst3c} = Assignment.create_employee_roster(emp_rst3, "inc_bata")
 {:ok, emp_rst4c} = Assignment.create_employee_roster(emp_rst4, "inc_bata")
 {:ok, emp_rst5c} = Assignment.create_employee_roster(emp_rst5, "inc_bata")
 {:ok, emp_rst6c} = Assignment.create_employee_roster(emp_rst6, "inc_bata")

 admin = %{
  "full_name" => "Admin User",
  "username" => "adminuser@inconn.com",
  "password" => "password"
 }
{:ok, admin_c} = Common.create_admin_user(admin)

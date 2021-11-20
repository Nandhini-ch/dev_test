alias Inconn2Service.{Staff, Assignment, Settings}

org_ut1 = %{"name" => "House Keeping", "party_id" => 1}

{:ok, org_ut1c} = Staff.create_org_unit(org_ut1, "inc_uds")


# feat1 = %{"name" => "Create sites", "code" => "CRST", "description" => "Can create site"}
# feat2 = %{"name" => "Create Asset", "code" => "CRAS", "description" => "Can create locations and equipment"}
# feat3 = %{"name" => "Create Employee", "code" => "CREM", "description" => "Can create employees"}
# feat4 = %{"name" => "Work order creation", "code" => "WOCR", "description" => "Can create workorders"}
# feat5 = %{"name" => "Work order execution", "code" => "WOEX", "description" => "Can execute workorders"}
#
# {:ok, feat1c} = Staff.create_feature(feat1, "inc_uds")
# {:ok, feat2c} = Staff.create_feature(feat2, "inc_uds")
# {:ok, feat3c} = Staff.create_feature(feat3, "inc_uds")
# {:ok, feat4c} = Staff.create_feature(feat4, "inc_uds")
# {:ok, feat5c} = Staff.create_feature(feat5, "inc_uds")
#
# role1 = %{"name" => "Super admin", "description" => "Has all access", "feature_ids" => [feat1c.id, feat2c.id, feat3c.id]}
# role2 = %{"name" => "Site Admin", "description" => "Has access to assets", "feature_ids" => [feat2c.id, feat3c.id, feat4c.id]}
# role3 = %{"name" => "supervisor", "description" => "Execution of work flows", "feature_ids" => [feat5c.id]}
#
# {:ok, role1c} = Staff.create_role(role1, "inc_uds")
# {:ok, role2c} = Staff.create_role(role2, "inc_uds")
# {:ok, role3c} = Staff.create_role(role3, "inc_uds")

employee1 = %{
  "employee_id" => "Empid0001",
  "mobile_no" => "7305556558",
  "designation" => "Manager - Engineering Services",
  "email" => "arul.nambi@uds.in",
  "first_name" => "Arul Nambi",
  "last_name" =>  "S",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1,
  "role_ids" => [1]
}
{:ok, emp_cs1} = Staff.create_employee(employee1,"inc_uds")

employee2 = %{
  "employee_id" => "Empid0002",
  "mobile_no" => "7373844860",
  "designation" => "Support Engineering",
  "email" => "gokulakrishnan.a@uds.in",
  "first_name" => "Gokulakrishnan",
  "last_name" =>  "Arumugam",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1,
  "role_ids" => [3]
}

{:ok, emp_cs2} = Staff.create_employee(employee2,"inc_uds")

employee3 = %{
  "employee_id" => "Empid0003",
  "mobile_no" => "9876543210",
  "designation" => "Supervisor",
  "email" => "earnest.p@inconn.com",
  "first_name" => "Earnest Josh",
  "last_name" =>  "Paul",
  "has_login_credentials" => true,
  "skills" => [1],
  "org_unit_id" =>  1,
  "party_id" => 1,
  "role_ids" => [4]
}

{:ok, emp_cs3} = Staff.create_employee(employee3,"inc_uds")

shift1 = %{"name" => "shift1", "start_date" => "2021-01-01", "end_date" => "2023-12-31",
"start_time" => "08:00:00", "end_time" => "20:00:00", "applicable_days" => [1,2,3,4,5], "site_id" => 1}

shift2 = %{"name" => "shift2", "start_date" => "2021-01-01", "end_date" => "2023-12-31",
"start_time" => "06:00:00", "end_time" => "14:00:00", "applicable_days" => [1,2,3,4,5], "site_id" => 1}

shift3 = %{"name" => "shift3", "start_date" => "2021-01-01", "end_date" => "2023-12-31",
"start_time" => "14:00:00", "end_time" => "22:00:00", "applicable_days" => [1,2,3,4,5], "site_id" => 1}

shift4 = %{"name" => "shift4", "start_date" => "2021-01-01", "end_date" => "2023-12-31",
"start_time" => "22:00:00", "end_time" => "04:00:00", "applicable_days" => [6,7], "site_id" => 1}

{:ok, shift1_c} = Settings.create_shift(shift1,"inc_uds")
{:ok, shift2_c} = Settings.create_shift(shift2,"inc_uds")
{:ok, shift3_c} = Settings.create_shift(shift3,"inc_uds")
{:ok, shift4_c} = Settings.create_shift(shift4,"inc_uds")

emp_rst1 = %{
  "employee_id" => 3,
  "site_id" => 1,
  "shift_id" => shift2_c.id,
  "start_date" => "2021-01-01",
  "end_date" => "2021-12-31"
}
emp_rst2 = %{
  "employee_id" => 3,
  "site_id" => 1,
  "shift_id" => shift1_c.id,
  "start_date" => "2021-01-01",
  "end_date" => "2021-12-31"
}

emp_rst3 = %{
  "employee_id" => 3,
  "site_id" => 1,
  "shift_id" => shift2_c.id,
  "start_date" => "2022-01-01",
  "end_date" => "2023-12-31"
}
 {:ok, emp_rst1c} = Assignment.create_employee_roster(emp_rst1, "inc_uds")
 {:ok, emp_rst2c} = Assignment.create_employee_roster(emp_rst2, "inc_uds")
 {:ok, emp_rst3c} = Assignment.create_employee_roster(emp_rst3, "inc_uds")

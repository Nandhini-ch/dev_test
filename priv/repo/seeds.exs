# Build the tiezone DB only once in production
alias Inconn2Service.Common
Common.build_timezone_db()

alias Inconn2Service.{Account, AssetConfig, WorkOrderConfig, CheckListConfig, Workorder, Staff}

bt = %{"name" => "Shoe Retail"}
{:ok, btrec} = Account.create_business_type(bt)

client = %{
  "company_name" => "Bata Shoe Company",
  "business_type_id" => btrec.id,
  "sub_domain" => "bata",
  "party_type" => "AO",
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

# case IO.inspect(Account.create_licensee(client)) do
# {:ok, lic} -> IO.inspect(lic)
# {:error, cs} -> IO.inspect(cs)
# _ -> IO.inspect()
# end
IO.inspect(Account.create_licensee(client))

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

a1 = %{"name" => "Open floor", "asset_type" => "L"}
a2 = %{"name" => "Electrical", "asset_type" => "E"}
{:ok, a1c} = AssetConfig.create_asset_category(a1, "inc_bata")
{:ok, a2c} = AssetConfig.create_asset_category(a2, "inc_bata")

b1 = %{
  "name" => "Building1",
  "location_code" => "LOC_BUILD1",
  "site_id" => sc.id,
  "asset_category_id" => a1c.id
}

b2 = %{
  "name" => "Building2",
  "location_code" => "LOC_BUILD2",
  "site_id" => sc.id,
  "asset_category_id" => a1c.id
}

{:ok, b1c} = AssetConfig.create_location(b1, "inc_bata")
{:ok, b2c} = AssetConfig.create_location(b2, "inc_bata")

{:ok, b1_f1} =
  %{
    "parent_id" => b1c.id,
    "name" => "B1 Floor1",
    "location_code" => "LOC_B1F1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b1_f2} =
  %{
    "parent_id" => b1c.id,
    "name" => "B1 Floor2",
    "location_code" => "LOC_B1F2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1} =
  %{
    "parent_id" => b2c.id,
    "name" => "B2 Floor1",
    "location_code" => "LOC_B2F1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f2} =
  %{
    "parent_id" => b2c.id,
    "name" => "B2 Floor2",
    "location_code" => "LOC_B2F2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b1_f1_z1} =
  %{
    "parent_id" => b1_f1.id,
    "name" => "B1 F1 Zone1",
    "location_code" => "LOC_B1F1Z1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b1_f1_z2} =
  %{
    "parent_id" => b1_f1.id,
    "name" => "B1 F1 Zone2",
    "location_code" => "LOC_B1F1Z2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1_z1} =
  %{
    "parent_id" => b2_f1.id,
    "name" => "B2 F1 Zone1",
    "location_code" => "LOC_B2F1Z1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1_z2} =
  %{
    "parent_id" => b2_f1.id,
    "name" => "B2 F1 Zone2",
    "location_code" => "LOC_B2F1Z2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1_z3} =
  %{
    "parent_id" => b2_f1.id,
    "name" => "B2 F1 Zone3",
    "location_code" => "LOC_B2F1Z3",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

dg1 = %{
  "name" => "Diesel Generator 1",
  "equipment_code" => "EQ_DG1",
  "site_id" => sc.id,
  "location_id" => b1c.id,
  "asset_category_id" => a2c.id
}

dg2 = %{
  "name" => "Diesel Generator 2",
  "equipment_code" => "EQ_DG2",
  "site_id" => sc.id,
  "location_id" => b1c.id,
  "asset_category_id" => a2c.id
}

{:ok, dg1c} = AssetConfig.create_equipment(dg1, "inc_bata")
{:ok, dg2c} = AssetConfig.create_equipment(dg2, "inc_bata")

{:ok, dg1_ic} =
  %{
    "parent_id" => dg1c.id,
    "name" => "IC Engine",
    "equipment_code" => "EQ_DG1_IC",
    "site_id" => sc.id,
    "location_id" => b1c.id,
    "asset_category_id" => a2c.id
  }
  |> AssetConfig.create_equipment("inc_bata")

{:ok, dg1_al} =
  %{
    "parent_id" => dg1c.id,
    "name" => "Alternator",
    "equipment_code" => "EQ_DG1_AL",
    "site_id" => sc.id,
    "location_id" => b1c.id,
    "asset_category_id" => a2c.id
  }
  |> AssetConfig.create_equipment("inc_bata")

{:ok, dg2_ic} =
  %{
    "parent_id" => dg2c.id,
    "name" => "IC Engine",
    "equipment_code" => "EQ_DG2_IC",
    "site_id" => sc.id,
    "location_id" => b1c.id,
    "asset_category_id" => a2c.id
  }
  |> AssetConfig.create_equipment("inc_bata")

{:ok, dg2_al} =
  %{
    "parent_id" => dg2c.id,
    "name" => "Alternator",
    "equipment_code" => "EQ_DG2_AL",
    "site_id" => sc.id,
    "location_id" => b1c.id,
    "asset_category_id" => a2c.id
  }
  |> AssetConfig.create_equipment("inc_bata")

tsk1 = %{
  "label" => "Task 1",
  "task_type" => "Inspection_one",
  "estimated_time" => 60,
  "config" => %{"label" => "abc", "value" => 30}
}

tsk2 = %{
  "label" => "Task 2",
  "task_type" => "Inspection_many",
  "estimated_time" => 120,
  "config" => %{"label" => "cde", "value" => 100}
}

tsk3 = %{
  "label" => "Task 3",
  "task_type" => "Metering",
  "estimated_time" => 15,
  "config" => %{"UOM" => "ampere", "type" => "A"}
}

tsk4 = %{
  "label" => "Task 4",
  "task_type" => "Observation",
  "estimated_time" => 90,
  "config" => %{"Observation" => "Observered certain things"}
}

{:ok, tsk1c} = WorkOrderConfig.create_task(tsk1, "inc_bata")
{:ok, tsk2c} = WorkOrderConfig.create_task(tsk2, "inc_bata")
{:ok, tsk3c} = WorkOrderConfig.create_task(tsk3, "inc_bata")
{:ok, tsk4c} = WorkOrderConfig.create_task(tsk4, "inc_bata")

tsk_lst1 = %{"name" => "Daily maintenance", "task_ids" => [1, 2], "asset_category_id" => 2}
tsk_lst2 = %{"name" => "Weakly maintenance", "task_ids" => [1, 2, 3], "asset_category_id" => 2}
tsk_lst3 = %{"name" => "Monthly maintenance", "task_ids" => [1, 3, 4], "asset_category_id" => 2}
{:ok, tsk_lst1c} = WorkOrderConfig.create_task_list(tsk_lst1, "inc_bata")
{:ok, tsk_lst2c} = WorkOrderConfig.create_task_list(tsk_lst2, "inc_bata")
{:ok, tsk_lst3c} = WorkOrderConfig.create_task_list(tsk_lst3, "inc_bata")

chk1 = %{"label" => "check 1", "type" => "WP"}
chk2 = %{"label" => "check 2", "type" => "WP"}
chk3 = %{"label" => "check 3", "type" => "LOTO"}
chk4 = %{"label" => "check 4", "type" => "LOTO"}

{:ok, chk1c} = CheckListConfig.create_check(chk1, "inc_bata")
{:ok, chk2c} = CheckListConfig.create_check(chk2, "inc_bata")
{:ok, chk3c} = CheckListConfig.create_check(chk3, "inc_bata")
{:ok, chk4c} = CheckListConfig.create_check(chk4, "inc_bata")

chk_lst1 = %{"name" => "check list 1", "type" => "WP", "check_ids" => [1, 2]}
chk_lst2 = %{"name" => "check list 2", "type" => "LOTO", "check_ids" => [3, 4]}

{:ok, chk_lst1c} = CheckListConfig.create_check_list(chk_lst1, "inc_bata")
{:ok, chk_lst2c} = CheckListConfig.create_check_list(chk_lst2, "inc_bata")

wkord_tp1 = %{
  "asset_category_id" => 2,
  "name" => "Hourly maintenance",
  "task_list_id" => 1,
  "tasks" => [%{"id" => 3, "order" => 1}, %{"id" => 4, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 4,
  "repeat_unit" => "H",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2021-08-29",
  "time_start" => "09:00:00",
  "time_end" => "17:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp2 = %{
  "asset_category_id" => 2,
  "name" => "Daily maintenance",
  "task_list_id" => 1,
  "tasks" => [%{"id" => 3, "order" => 1}, %{"id" => 4, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "D",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2021-09-30",
  "time_start" => "09:00:00",
  "time_end" => "17:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp3 = %{
  "asset_category_id" => 2,
  "name" => "Weekly maintenance",
  "task_list_id" => 1,
  "tasks" => [%{"id" => 3, "order" => 1}, %{"id" => 4, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "W",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2021-12-31",
  "time_start" => "09:00:00",
  "time_end" => "17:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => true,
  "workpermit_check_list_id" => chk_lst1c.id,
  "loto_required" => false
}

wkord_tp4 = %{
  "asset_category_id" => 2,
  "name" => "Monthly maintenance",
  "task_list_id" => 1,
  "tasks" => [%{"id" => 3, "order" => 1}, %{"id" => 4, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "M",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2022-08-27",
  "time_start" => "09:00:00",
  "time_end" => "17:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => false,
  "loto_required" => true,
  "loto_lock_check_list_id" => chk_lst2c.id,
  "loto_release_check_list_id" => chk_lst2c.id
}

wkord_tp5 = %{
  "asset_category_id" => 2,
  "name" => "Yearly maintenance",
  "task_list_id" => 1,
  "tasks" => [%{"id" => 3, "order" => 1}, %{"id" => 4, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "Y",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2025-08-27",
  "time_start" => "09:00:00",
  "time_end" => "17:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => true,
  "workpermit_check_list_id" => chk_lst1c.id,
  "loto_required" => true,
  "loto_lock_check_list_id" => chk_lst2c.id,
  "loto_release_check_list_id" => chk_lst2c.id
}

{:ok, wkord_tp1c} = Workorder.create_workorder_template(wkord_tp1, "inc_bata")
{:ok, wkord_tp2c} = Workorder.create_workorder_template(wkord_tp2, "inc_bata")
{:ok, wkord_tp3c} = Workorder.create_workorder_template(wkord_tp3, "inc_bata")
{:ok, wkord_tp4c} = Workorder.create_workorder_template(wkord_tp4, "inc_bata")
{:ok, wkord_tp5c} = Workorder.create_workorder_template(wkord_tp5, "inc_bata")

wkord_sc1 = %{"workorder_template_id" => 1, "asset_id" => 1, "config" => %{"time" => "09:00:00"}}
wkord_sc2 = %{"workorder_template_id" => 2, "asset_id" => 1, "config" => %{"date" => "2021-09-01", "time" => "09:00:00"}}
wkord_sc3 = %{"workorder_template_id" => 3, "asset_id" => 1, "config" => %{"day" => 4, "time" => "09:00:00"}}
wkord_sc4 = %{"workorder_template_id" => 4, "asset_id" => 1, "config" => %{"day" => 15, "time" => "09:00:00"}}
wkord_sc5 = %{"workorder_template_id" => 5, "asset_id" => 1, "config" => %{"day" => 15, "month" => 11, "time" => "09:00:00"}}

{:ok, wkord_sc1c} = Workorder.create_workorder_schedule(wkord_sc1, "Europe/Berlin", "inc_bata")
{:ok, wkord_sc2c} = Workorder.create_workorder_schedule(wkord_sc2, "Indian/Maldives", "inc_bata")
{:ok, wkord_sc3c} = Workorder.create_workorder_schedule(wkord_sc3, "Australia/Melbourne", "inc_bata")
{:ok, wkord_sc4c} = Workorder.create_workorder_schedule(wkord_sc4, "Asia/Tokyo", "inc_bata")
{:ok, wkord_sc5c} = Workorder.create_workorder_schedule(wkord_sc5, "America/New_York", "inc_bata")

org_ut1 = %{"name" => "Electrical", "party_id" => 1}
org_ut2 = %{"name" => "Mechanical", "party_id" => 1}
org_ut3 = %{"name" => "AHU", "party_id" => 1, "parent_id" => 2}
org_ut4 = %{"name" => "Controllers", "party_id" => 1, "parent_id" => 3}

{:ok, org_ut1c} = Staff.create_org_unit(org_ut1, "inc_bata")
{:ok, org_ut2c} = Staff.create_org_unit(org_ut2, "inc_bata")
{:ok, org_ut3c} = Staff.create_org_unit(org_ut3, "inc_bata")
{:ok, org_ut4c} = Staff.create_org_unit(org_ut4, "inc_bata")

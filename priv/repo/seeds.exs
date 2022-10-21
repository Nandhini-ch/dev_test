# Build the tiezone DB only once in production
alias Inconn2Service.Common
Common.build_timezone_db()

alias Inconn2Service.{Account, AssetConfig, WorkOrderConfig, CheckListConfig, Staff}

bt = %{"name" => "Shoe Retail"}
{:ok, btrec} = Account.create_business_type(bt)

bt2 = %{"name" => "Facility Management"}
{:ok, btrec2} = Account.create_business_type(bt2)


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
    "mobile" => "hello123",
    "email" => "balac@bata.co.in"
  }
}

# case IO.inspect(Account.create_licensee(client)) do
# {:ok, lic} -> IO.inspect(lic)
# {:error, cs} -> IO.inspect(cs)
# _ -> IO.inspect()
# end
IO.inspect(Account.create_licensee(client))
# IO.inspect(Account.create_licensee(client2))

party = %{
  "company_name" => "UDS",
  "party_type" => "SP",
  "licensee" => false
}

pc =
  case IO.inspect(AssetConfig.create_party(party, "inc_bata")) do
    {:ok, party_created} -> IO.inspect(party_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

zone_1 = %{"name" => "zone 1"}
{:ok, zn1_c} = AssetConfig.create_zone(zone_1, "inc_bata")

zone_2 = %{"name" => "zone 2", "parent_id" => zn1_c.id}
{:ok, zn2_c} = AssetConfig.create_zone(zone_2, "inc_bata")

zone_3 = %{"name" => "zone 3", "parent_id" => zn2_c.id}
{:ok, zn3_c} = AssetConfig.create_zone(zone_3, "inc_bata")

site_1 = %{
  "name" => "Mountroad",
  "description" => "Main branch at Mount road",
  "site_code" => "BRCHN_MNTRD",
  "party_id" => 1,
  "zone_id" => zn2_c.id,
  "time_zone" => "Europe/Berlin",
  "address" => %{
    "address_line1" => "18, First Street",
    "address_line2" => "Mountroad",
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

site_2 = %{
  "name" => "Test",
  "description" => "Main branch at Mount road",
  "site_code" => "TEST",
  "party_id" => 1,
  "zone_id" => zn2_c.id,
  "time_zone" => "Europe/Berlin",
  "address" => %{
    "address_line1" => "18, First Street",
    "address_line2" => "Mountroad",
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
    "email" => "ba@bata.co.in"
  }
}

# site2 = %{
#   "name" => "HCCB - COCA COLA",
#   "description" => "HINDUSTAN COCA COLA BEVERAGES PVT LTD",
#   "area" => 500,
#   "latitude" => 15.371807,
#   "longitude" => 73.947236,
#   "fencing_radius" => 500,
#   "site_code" => "Asia/Kolkata",
#   "party_id" => 1,
#   "time_zone" => "Europe/Berlin",
#   "address" => %{
#     "address_line1" => "M2 To M11 Phase III B Industrial Estate",
#     "address_line2" => "Verna Industrial Estate Verna",
#     "city" => "Baneji",
#     "state" => "GOA",
#     "country" => "India",
#     "postcode" => "403722"
#   },
#   "contact" => %{
#     "first_name" => "Bala",
#     "last_name" => "Chandar",
#     "designation" => "Sales Head",
#     "land_line" => "+91-44-2457727",
#     "mobile" => "+91-9840022485",
#     "email" => "balac@bata.co.in"
#   }
# }

{:ok, sc} = AssetConfig.create_site(site_1, "inc_bata")
{:ok, sc_2} = AssetConfig.create_site(site_2, "inc_bata")

si_cf1 = %{
  "site_id" => sc.id,
  "type" => "ATT",
  "config" => %{
    "preferred_total_work_hours" => 480,
    "half_day_work_hours" => 210,
    "grace_period_for_in_time" => 15
  }
}

{:ok, si_cf1c} = AssetConfig.create_site_config(si_cf1, "inc_bata")
# sc2 =
#   case IO.inspect(AssetConfig.create_site(site2, "inc_cola")) do
#     {:ok, site_created} -> IO.inspect(site_created)
#     {:error, cs} -> IO.inspect(cs)
#     nil -> IO.puts("null value returned")
#   end


alias Inconn2Service.Common
alias Inconn2Service.Prompt

alerts = Common.list_alert_notification_reserves()

Enum.map(alerts, fn alert ->
Prompt.create_alert_notification_config(
  %{
      "addressed_to_user_ids" => [1,2],
      "alert_notification_reserve_id" => alert.id,
      "is_escalation_required" => true,
      "escalated_to_user_ids" => [4, 5],
      "escalation_time_in_minutes" => 1,
      "site_id" => 1
    },
    "inc_bata"
  )
end)


a1 = %{"name" => "Open floor", "asset_type" => "L"}
a2 = %{"name" => "Electrical", "asset_type" => "E"}
a3 = %{"name" => "HouseKeeping", "asset_type" => "L"}
{:ok, a1c} = AssetConfig.create_asset_category(a1, "inc_bata")
{:ok, a2c} = AssetConfig.create_asset_category(a2, "inc_bata")


b1 = %{
  "name" => "Building1",
  "location_code" => "LOC_BUILD1",
  "site_id" => sc.id,
  "asset_category_id" => a1c.id,
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
  "asset_category_id" => a2c.id,
}

dg2 = %{
  "name" => "Diesel Generator 2",
  "equipment_code" => "EQ_DG2",
  "site_id" => sc.id,
  "location_id" => b2_f1_z3.id,
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
    "asset_category_id" => a2c.id,
    "connections_in" => [1],
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
    "location_id" => b2_f1_z3.id,
    "asset_category_id" => a2c.id
  }
  |> AssetConfig.create_equipment("inc_bata")

{:ok, dg2_al} =
  %{
    "parent_id" => dg2c.id,
    "name" => "Alternator",
    "equipment_code" => "EQ_DG2_AL",
    "site_id" => sc.id,
    "location_id" => b2_f1_z3.id,
    "asset_category_id" => a2c.id
  }
  |> AssetConfig.create_equipment("inc_bata")

mas_tsk_type1 = %{
  "name" => "Task type 1",
  "description" => "description 1"
}

mas_tsk_type2 = %{
  "name" => "Task type 2",
  "description" => "description 2"
}

{:ok, mas_tsk_type1c} = WorkOrderConfig.create_master_task_type(mas_tsk_type1, "inc_bata")
{:ok, mas_tsk_type2c} = WorkOrderConfig.create_master_task_type(mas_tsk_type2, "inc_bata")

tsk1 = %{
  "label" => "Task 1",
  "task_type" => "IO",
  "master_task_type_id" => mas_tsk_type1c.id,
  "estimated_time" => 60,
  "config" => %{
            "options" => [ %{"label" => "abc", "value" => "P", "raise_ticket" => false},
                           %{"label" => "xyz", "value" => "F", "raise_ticket" => true} ]
            }
}

tsk2 = %{
  "label" => "Task 2",
  "task_type" => "IM",
  "master_task_type_id" => mas_tsk_type1c.id,
  "estimated_time" => 120,
  "config" => %{
            "options" => [ %{"label" => "abc", "value" => "P", "raise_ticket" => false},
                           %{"label" => "xyz", "value" => "F", "raise_ticket" => true},
                           %{"label" => "qwe", "value" => "A", "raise_ticket" => false} ]
            }
}

tsk3 = %{
  "label" => "Task 3",
  "task_type" => "MT",
  "master_task_type_id" => mas_tsk_type2c.id,
  "estimated_time" => 15,
  "config" => %{"meter_type" => "E", "UOM" => "ampere", "type" => "A", "min_value" => 10, "max_value" => 1000, "threshold_value" => 700}
}

tsk4 = %{
  "label" => "Task 4",
  "task_type" => "OB",
  "master_task_type_id" => mas_tsk_type2c.id,
  "estimated_time" => 90,
  "config" => %{"min_length" => 10, "max_length" => 100}
}

{:ok, tsk1c} = WorkOrderConfig.create_task(tsk1, "inc_bata")
{:ok, tsk2c} = WorkOrderConfig.create_task(tsk2, "inc_bata")
{:ok, tsk3c} = WorkOrderConfig.create_task(tsk3, "inc_bata")
{:ok, tsk4c} = WorkOrderConfig.create_task(tsk4, "inc_bata")

tsk_lst1 = %{"name" => "Daily maintenance", "tasks" => [%{"task_id" => 1, "sequence" => 1}, %{"task_id" => 2, "sequence" => 2}], "asset_category_id" => 2}
tsk_lst2 = %{"name" => "Weakly maintenance", "tasks" => [%{"task_id" => 1, "sequence" => 1}, %{"task_id" => 2, "sequence" => 2}, %{"task_id" => 3, "sequence" => 3}], "asset_category_id" => 2}
tsk_lst3 = %{"name" => "Monthly maintenance", "tasks" => [%{"task_id" => 1, "sequence" => 1}, %{"task_id" => 3, "sequence" => 2}, %{"task_id" => 4, "sequence" => 3}], "asset_category_id" => 2}
{:ok, tsk_lst1c} = WorkOrderConfig.create_task_list(tsk_lst1, "inc_bata")
{:ok, tsk_lst2c} = WorkOrderConfig.create_task_list(tsk_lst2, "inc_bata")
{:ok, tsk_lst3c} = WorkOrderConfig.create_task_list(tsk_lst3, "inc_bata")

org_ut1 = %{"name" => "Electrical", "party_id" => 1}
org_ut2 = %{"name" => "Mechanical", "party_id" => 1}
org_ut3 = %{"name" => "AHU", "party_id" => 1, "parent_id" => 2}
org_ut4 = %{"name" => "Controllers", "party_id" => 1, "parent_id" => 3}

{:ok, org_ut1c} = Staff.create_org_unit(org_ut1, "inc_bata")
{:ok, org_ut2c} = Staff.create_org_unit(org_ut2, "inc_bata")
{:ok, org_ut3c} = Staff.create_org_unit(org_ut3, "inc_bata")
{:ok, org_ut4c} = Staff.create_org_unit(org_ut4, "inc_bata")

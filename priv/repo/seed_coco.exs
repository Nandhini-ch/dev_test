# Build the tiezone DB only once in production
alias Inconn2Service.Common
Common.build_timezone_db()

alias Inconn2Service.{Account, AssetConfig, WorkOrderConfig, Workorder}

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
    "land_line" => "+91-44-2457727",
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

site = %{
  "name" => "HCCB - COCA COLA",
  "description" => "HINDUSTAN COCA COLA BEVERAGES PVT LTD",
  "branch" => "GOA",
  "area" => 500,
  "latitude" => 15.371807,
  "longitude" => 73.947236,
  "fencing_radius" => 500,
  "site_code" => "HCCFB",
  "party_id" => 2,
  "time_zone" => "Asia/Kolkata",
  "address" => %{
    "address_line1" => "M2 To M11 Phase III B, Industrial Estate",
    "address_line2" => "Verna Industrial Estate, Verna",
    "city" => "Baneji",
    "state" => "GOA",
    "country" => "INDIA",
    "postcode" => "403722"
  },
  "contact" => %{
    "first_name" => "Bhoju",
    "last_name" => "S",
    "designation" => "Operation Manager",
    "land_line" => "+91-44-2457727",
    "mobile" => "+91-9823259569",
    "email" => "bhoju.s@uds.in"
    }
}

sc =
  case IO.inspect(AssetConfig.create_site(site, "inc_uds")) do
    {:ok, site_created} -> IO.inspect(site_created)
    {:error, cs} -> IO.inspect(cs)
    nil -> IO.puts("null value returned")
  end

a1 = %{"name" => "House Keeping", "asset_type" => "L"}
{:ok, a1c} = AssetConfig.create_asset_category(a1, "inc_uds")

{:ok, l1c} = %{
        "name" => "HCCB",
        "description" => "HINDUSTAN COCA COLA BEVERAGES PVT LTD",
        "location_code" => "HCCB - GOA - ALL - L -1001",
        "site_id" => sc.id,
        "asset_category_id" => a1c.id
      }
      |> AssetConfig.create_location("inc_uds")

{:ok, l2c} = %{
        "name" => "HCCB - PRODUCTION AREA",
        "description" => "HCCB - PRODUCTION AREA",
        "location_code" => "HCCB - GOA - PRO - L -1003",
        "site_id" => sc.id,
        "asset_category_id" => a1c.id,
        "parent_id" => l1c.id
      }
      |> AssetConfig.create_location("inc_uds")

{:ok, l3c} = %{
        "name" => "PROD AREA - PET PACKAGE AREA",
        "description" => "PROD AREA - PET PACKAGE AREA",
        "location_code" => "HCCB - GOA - PRO - PETP - 1020",
        "site_id" => sc.id,
        "asset_category_id" => a1c.id,
        "parent_id" => l2c.id
      }
      |> AssetConfig.create_location("inc_uds")

tsk1 = %{
    "label" => "Brooming and Mopping of floor surrounding the area",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Dry floor and free from any foreign particles(paper,closures,carton pieces, PET etc.)", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
                }
}

tsk2 = %{
    "label" => "Cleaning and wiping of water from the floor/ wall corners",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Dry floor and free from any foreign particles(paper,closures,carton pieces, PET etc.)", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk3 = %{
    "label" => "Removal of unwanted material",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Should be free from foreign particles", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk4 = %{
    "label" => "Date coder check for spillages of ink on floor",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust ,dirt & stains", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk5 = %{
    "label" => "Cleaning of Drains",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "No contamination through paper, carton pieces & molds", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk6 = %{
    "label" => "Floor cleaning with machine",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Single disc", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk7 = %{
    "label" => "Mat cleaning",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk8 = %{
    "label" => "Chucker plate & preform station cleaning",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk9 = %{
    "label" => "Cleaning under the Panels & panel mats",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust and dirt", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk10 = %{
    "label" => "Cleaning of dustbin",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "No over accumulation of waste", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk11 = %{
    "label" => "Proper place for HK tools with label",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Color coded and properly stacked", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk12 = %{
    "label" => "Removal of opened bottles",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "No loose bottles scattered in area", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk13 = %{
    "label" => "Cleaning of conveyor trays",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust and dirt", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk14 = %{
    "label" => "Mold growth removal from floors, tiles, walls, equipment surfaces & electrical wires etc",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dirt, dust, mold, slimy film, rust stains", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk15 = %{
    "label" => "Cleaning of hand wash stations  & refilling the dispensers with soap soln. & sanitizer",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Clean area with soap soln. & sanitizer available at all times", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk16 = %{
    "label" => "Conveyor drip tray cleaning",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "High pressure jet", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk17 = %{
    "label" => "Eye washer cleaning",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust and dirt", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk18 = %{
    "label" => "Dusting of air curtain with extension rod & feather brush  cleaning the stains with cotton cloth",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust, dirt and stains", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk19 = %{
    "label" => "Cleaning of glass windows & doors",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust , dirt and stains", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk20 = %{
    "label" => "S.S / M.S / G.I. Pipelines cleaning",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust and rusting", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk21 = %{
    "label" => "External Tanks extensive cleaning",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from rust, dirt and dust", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk22 = %{
    "label" => "Cleaning of pestolight with duster and removal of spider pads",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust , dirt and stains", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk23 = %{
    "label" => "Cleaning of Ceiling lamps for dust and any sticky material",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust , dirt and stains", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk24 = %{
    "label" => "Cleaning of supporters, angles, cable trays",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust and dirt", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk25 = %{
    "label" => "Cleaning of walls, tiles & columns and removal of cobwebs",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dust and dirt and traces of cobwebs,live insects", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

tsk26 = %{
    "label" => "Light Cleaning",
    "task_type" => "IO",
    "estimated_time" => 10,
    "config" => %{
                "options" => [ %{"label" => "Free from dirt and dust", "value" => "P"},
                               %{"label" => "NOT OK", "value" => "F"} ]
              }
}

{:ok, tsk1c} = WorkOrderConfig.create_task(tsk1, "inc_uds")
{:ok, tsk2c} = WorkOrderConfig.create_task(tsk2, "inc_uds")
{:ok, tsk3c} = WorkOrderConfig.create_task(tsk3, "inc_uds")
{:ok, tsk4c} = WorkOrderConfig.create_task(tsk4, "inc_uds")
{:ok, tsk5c} = WorkOrderConfig.create_task(tsk5, "inc_uds")
{:ok, tsk6c} = WorkOrderConfig.create_task(tsk6, "inc_uds")
{:ok, tsk7c} = WorkOrderConfig.create_task(tsk7, "inc_uds")
{:ok, tsk8c} = WorkOrderConfig.create_task(tsk8, "inc_uds")
{:ok, tsk9c} = WorkOrderConfig.create_task(tsk9, "inc_uds")
{:ok, tsk10c} = WorkOrderConfig.create_task(tsk10, "inc_uds")
{:ok, tsk11c} = WorkOrderConfig.create_task(tsk11, "inc_uds")
{:ok, tsk12c} = WorkOrderConfig.create_task(tsk12, "inc_uds")
{:ok, tsk13c} = WorkOrderConfig.create_task(tsk13, "inc_uds")
{:ok, tsk14c} = WorkOrderConfig.create_task(tsk14, "inc_uds")
{:ok, tsk15c} = WorkOrderConfig.create_task(tsk15, "inc_uds")
{:ok, tsk16c} = WorkOrderConfig.create_task(tsk16, "inc_uds")
{:ok, tsk17c} = WorkOrderConfig.create_task(tsk17, "inc_uds")
{:ok, tsk18c} = WorkOrderConfig.create_task(tsk18, "inc_uds")
{:ok, tsk19c} = WorkOrderConfig.create_task(tsk19, "inc_uds")
{:ok, tsk20c} = WorkOrderConfig.create_task(tsk20, "inc_uds")
{:ok, tsk21c} = WorkOrderConfig.create_task(tsk21, "inc_uds")
{:ok, tsk22c} = WorkOrderConfig.create_task(tsk22, "inc_uds")
{:ok, tsk23c} = WorkOrderConfig.create_task(tsk23, "inc_uds")
{:ok, tsk24c} = WorkOrderConfig.create_task(tsk24, "inc_uds")
{:ok, tsk25c} = WorkOrderConfig.create_task(tsk25, "inc_uds")
{:ok, tsk26c} = WorkOrderConfig.create_task(tsk26, "inc_uds")

tsk_lst1 = %{"name" => "PET - PACKAGING HALL ONCE IN 4 HRS CHECK", "task_ids" => [tsk1c.id], "asset_category_id" => 1}
tsk_lst2 = %{"name" => "PET - PACKAGING HALL DAILY CHECK", "task_ids" => [tsk2c.id, tsk3c.id, tsk4c.id, tsk5c.id, tsk6c.id, tsk7c.id, tsk8c.id, tsk9c.id, tsk10c.id, tsk11c.id, tsk12c.id, tsk13c.id, tsk14c.id, tsk15c.id, tsk16c.id, tsk17c.id], "asset_category_id" => 1}
tsk_lst3 = %{"name" => "PET - PACKAGING HALL WEEKLY CHECK", "task_ids" => [tsk18c.id, tsk19c.id], "asset_category_id" => 1}
tsk_lst4 = %{"name" => "PET - PACKAGING HALL MONTHLY CHECK", "task_ids" => [tsk20c.id, tsk21c.id], "asset_category_id" => 1}
tsk_lst5 = %{"name" => "PET - PACKAGING HALL TWICE IN WEEK CHECK", "task_ids" => [tsk22c.id], "asset_category_id" => 1}
tsk_lst6 = %{"name" => "PET - PACKAGING HALL CHECK TWICE IN MONTH FORTNIGHT", "task_ids" => [tsk23c.id, tsk24c.id, tsk25c.id, tsk26c.id], "asset_category_id" => 1}

{:ok, tsk_lst1c} = WorkOrderConfig.create_task_list(tsk_lst1, "inc_uds")
{:ok, tsk_lst2c} = WorkOrderConfig.create_task_list(tsk_lst2, "inc_uds")
{:ok, tsk_lst3c} = WorkOrderConfig.create_task_list(tsk_lst3, "inc_uds")
{:ok, tsk_lst4c} = WorkOrderConfig.create_task_list(tsk_lst4, "inc_uds")
{:ok, tsk_lst5c} = WorkOrderConfig.create_task_list(tsk_lst5, "inc_uds")
{:ok, tsk_lst6c} = WorkOrderConfig.create_task_list(tsk_lst6, "inc_uds")

wkord_tp1 = %{
  "asset_category_id" => 1,
  "name" => "PET - PACKAGING HALL ONCE IN 4 HRS CHECK",
  "task_list_id" => 1,
  "tasks" => [%{"id" => tsk1c.id, "order" => 1}],
  "estimated_time" => 60,
  "scheduled" => true,
  "repeat_every" => 4,
  "repeat_unit" => "H",
  "applicable_start" => "2021-10-25",
  "applicable_end" => "2022-10-25",
  "time_start" => "09:00:00",
  "time_end" => "18:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 60,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp2 = %{
  "asset_category_id" => 1,
  "name" => "PET - PACKAGING HALL DAILY CHECK",
  "task_list_id" => 2,
  "tasks" => [%{"id" => tsk2c.id, "order" => 1}, %{"id" => tsk3c.id, "order" => 2}, %{"id" => tsk4c.id, "order" => 3}, %{"id" => tsk5c.id, "order" => 4},
              %{"id" => tsk6c.id, "order" => 5}, %{"id" => tsk7c.id, "order" => 6}, %{"id" => tsk8c.id, "order" => 7}, %{"id" => tsk9c.id, "order" => 8},
              %{"id" => tsk10c.id, "order" => 9}, %{"id" => tsk11c.id, "order" => 10}, %{"id" => tsk12c.id, "order" => 11}, %{"id" => tsk13c.id, "order" => 12},
              %{"id" => tsk14c.id, "order" => 13}, %{"id" => tsk15c.id, "order" => 14}, %{"id" => tsk16c.id, "order" => 15}, %{"id" => tsk17c.id, "order" => 16}],
  "estimated_time" => 160,
  "scheduled" => true,
  "repeat_every" => 1,
  "repeat_unit" => "D",
  "applicable_start" => "2021-10-25",
  "applicable_end" => "2022-10-25",
  #"time_start" => "09:00:00",
  #"time_end" => "18:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 60,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp3 = %{
  "asset_category_id" => 1,
  "name" => "PET - PACKAGING HALL WEEKLY CHECK",
  "task_list_id" => 3,
  "tasks" => [%{"id" => tsk18c.id, "order" => 1}, %{"id" => tsk19c.id, "order" => 2}],
  "estimated_time" => 60,
  "scheduled" => true,
  "repeat_every" => 1,
  "repeat_unit" => "W",
  "applicable_start" => "2021-10-25",
  "applicable_end" => "2022-10-25",
  #"time_start" => "09:00:00",
  #"time_end" => "18:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 60,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp4 = %{
  "asset_category_id" => 1,
  "name" => "PET - PACKAGING HALL MONTHLY CHECK",
  "task_list_id" => 4,
  "tasks" => [%{"id" => tsk20c.id, "order" => 1}, %{"id" => tsk21c.id, "order" => 2}],
  "estimated_time" => 60,
  "scheduled" => true,
  "repeat_every" => 1,
  "repeat_unit" => "M",
  "applicable_start" => "2021-10-25",
  "applicable_end" => "2022-10-25",
  # "time_start" => "09:00:00",
  # "time_end" => "18:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 60,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp5 = %{
  "asset_category_id" => 1,
  "name" => "PET - PACKAGING HALL TWICE IN WEEK CHECK",
  "task_list_id" => 5,
  "tasks" => [%{"id" => tsk22c.id, "order" => 1}],
  "estimated_time" => 60,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "W",
  "applicable_start" => "2021-10-25",
  "applicable_end" => "2022-10-25",
  # "time_start" => "09:00:00",
  # "time_end" => "18:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 60,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp6 = %{
  "asset_category_id" => 1,
  "name" => "PET - PACKAGING HALL CHECK TWICE IN MONTH FORTNIGHT",
  "task_list_id" => 6,
  "tasks" => [%{"id" => tsk23c.id, "order" => 1}, %{"id" => tsk24c.id, "order" => 2},
              %{"id" => tsk25c.id, "order" => 3}, %{"id" => tsk26c.id, "order" => 4}],
  "estimated_time" => 60,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "M",
  "applicable_start" => "2021-10-25",
  "applicable_end" => "2022-10-25",
  # "time_start" => "09:00:00",
  # "time_end" => "18:00:00",
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 60,
  "workpermit_required" => false,
  "loto_required" => false
}

{:ok, wkord_tp1c} = Workorder.create_workorder_template(wkord_tp1, "inc_uds")
{:ok, wkord_tp2c} = Workorder.create_workorder_template(wkord_tp2, "inc_uds")
{:ok, wkord_tp3c} = Workorder.create_workorder_template(wkord_tp3, "inc_uds")
{:ok, wkord_tp4c} = Workorder.create_workorder_template(wkord_tp4, "inc_uds")
{:ok, wkord_tp5c} = Workorder.create_workorder_template(wkord_tp5, "inc_uds")
{:ok, wkord_tp6c} = Workorder.create_workorder_template(wkord_tp6, "inc_uds")

wkord_sc1 = %{"workorder_template_id" => 1, "asset_id" => 3, "holidays" => [7], "first_occurrence_date" => "2021-11-12", "first_occurrence_time" => "09:00:00"}
wkord_sc2 = %{"workorder_template_id" => 2, "asset_id" => 3, "holidays" => [7], "first_occurrence_date" => "2021-11-12", "first_occurrence_time" => "09:00:00"}
wkord_sc3 = %{"workorder_template_id" => 3, "asset_id" => 3, "holidays" => [7], "first_occurrence_date" => "2021-11-13", "first_occurrence_time" => "09:00:00"}
wkord_sc4 = %{"workorder_template_id" => 4, "asset_id" => 3, "holidays" => [7], "first_occurrence_date" => "2021-11-13", "first_occurrence_time" => "12:00:00"}
wkord_sc5 = %{"workorder_template_id" => 5, "asset_id" => 3, "holidays" => [7], "first_occurrence_date" => "2021-11-13", "first_occurrence_time" => "15:00:00"}
wkord_sc6 = %{"workorder_template_id" => 6, "asset_id" => 3, "holidays" => [7], "first_occurrence_date" => "2021-11-13", "first_occurrence_time" => "18:00:00"}

{:ok, wkord_sc1c} = Workorder.create_workorder_schedule(wkord_sc1, "inc_uds")
{:ok, wkord_sc2c} = Workorder.create_workorder_schedule(wkord_sc2, "inc_uds")
{:ok, wkord_sc3c} = Workorder.create_workorder_schedule(wkord_sc3, "inc_uds")
{:ok, wkord_sc4c} = Workorder.create_workorder_schedule(wkord_sc4, "inc_uds")
{:ok, wkord_sc5c} = Workorder.create_workorder_schedule(wkord_sc5, "inc_uds")
{:ok, wkord_sc6c} = Workorder.create_workorder_schedule(wkord_sc6, "inc_uds")

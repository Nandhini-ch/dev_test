alias Inconn2Service.{CheckListConfig, Workorder, Ticket}

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
  "tasks" => [%{"id" => 3, "order" => 1}, %{"id" => 2, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 4,
  "repeat_unit" => "H",
  "applicable_start" => "2021-10-21",
  "applicable_end" => "2023-10-23",
  "time_start" => "09:00:00",
  "time_end" => "17:00:00",
  "create_new" => "at",
  "max_times" => 5,
  "consumables" => [%{"id" => 1, "uom_id" => 1, "quantity" => 10}, %{"id" => 2, "uom_id" => 1, "quantity" => 10}],
  "spares" => [%{"id" => 1, "uom_id" => 1, "quantity" => 10}, %{"id" => 5, "uom_id" => 1, "quantity" => 10}],
  "tools" => [%{"id" => 1, "uom_id" => 1, "quantity" => 10}],
  "workorder_prior_time" => 180,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp2 = %{
  "asset_category_id" => 2,
  "name" => "Daily maintenance",
  "task_list_id" => 2,
  "tasks" => [%{"id" => 1, "order" => 1}, %{"id" => 2, "order" => 2}, %{"id" => 3, "order" => 3}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "D",
  "applicable_start" => "2021-09-27",
  "applicable_end" => "2023-10-30",
  "time_start" => nil,
  "time_end" => nil,
  "create_new" => "at",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => false,
  "loto_required" => false
}

wkord_tp3 = %{
  "asset_category_id" => 2,
  "name" => "Weekly maintenance",
  "task_list_id" => 3,
  "tasks" => [%{"id" => 1, "order" => 1}, %{"id" => 3, "order" => 2}, %{"id" => 4, "order" => 3}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "W",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2023-12-31",
  "time_start" => nil,
  "time_end" => nil,
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => true,
  "status" => "wpp",
  "workpermit_required_from" => [2],
  "workpermit_check_list_id" => chk_lst1c.id,
  "loto_required" => false
}

wkord_tp4 = %{
  "asset_category_id" => 2,
  "name" => "Monthly maintenance",
  "task_list_id" => 1,
  "tasks" => [%{"id" => 1, "order" => 1}, %{"id" => 2, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "M",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2023-08-27",
  "time_start" => nil,
  "time_end" => nil,
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
  "tasks" => [%{"id" => 1, "order" => 1}, %{"id" => 2, "order" => 2}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 2,
  "repeat_unit" => "Y",
  "applicable_start" => "2021-08-27",
  "applicable_end" => "2025-08-27",
  "time_start" => nil,
  "time_end" => nil,
  "create_new" => "oc",
  "max_times" => 5,
  "workorder_prior_time" => 180,
  "workpermit_required" => true,
  "workpermit_check_list_id" => chk_lst1c.id,
  "loto_required" => true,
  "loto_lock_check_list_id" => chk_lst2c.id,
  "loto_release_check_list_id" => chk_lst2c.id
}

wkord_tp6 = %{
  "asset_category_id" => 1,
  "name" => "Hourly maintenance",
  "task_list_id" => 2,
  "tasks" => [%{"id" => 1, "order" => 1}, %{"id" => 2, "order" => 2}, %{"id" => 3, "order" => 3}],
  "estimated_time" => 286,
  "scheduled" => true,
  "repeat_every" => 4,
  "repeat_unit" => "H",
  "applicable_start" => "2021-10-21",
  "applicable_end" => "2023-10-23",
  "time_start" => "09:00:00",
  "time_end" => "17:00:00",
  "create_new" => "at",
  "max_times" => 5,
  "consumables" => [%{"id" => 1, "uom_id" => 1, "quantity" => 10}, %{"id" => 2, "uom_id" => 1, "quantity" => 10}],
  "spares" => [%{"id" => 1, "uom_id" => 1, "quantity" => 10}, %{"id" => 5, "uom_id" => 1, "quantity" => 10}],
  "tools" => [%{"id" => 1, "uom_id" => 1, "quantity" => 10}],
  "workorder_prior_time" => 180,
  "workpermit_required" => false,
  "loto_required" => false
}

{:ok, wkord_tp1c} = Workorder.create_workorder_template(wkord_tp1, "inc_bata")
{:ok, wkord_tp2c} = Workorder.create_workorder_template(wkord_tp2, "inc_bata")
{:ok, wkord_tp3c} = Workorder.create_workorder_template(wkord_tp3, "inc_bata")
{:ok, wkord_tp4c} = Workorder.create_workorder_template(wkord_tp4, "inc_bata")
{:ok, wkord_tp5c} = Workorder.create_workorder_template(wkord_tp5, "inc_bata")
{:ok, wkord_tp6c} = Workorder.create_workorder_template(wkord_tp6, "inc_bata")

wkord_sc1 = %{"workorder_template_id" => 1, "asset_id" => 1, "holidays" => [7], "first_occurrence_date" => "2022-02-15", "first_occurrence_time" => "09:00:00"}
wkord_sc2 = %{"workorder_template_id" => 2, "asset_id" => 1, "holidays" => [6,7], "first_occurrence_date" => "2022-02-15", "first_occurrence_time" => "09:00:00"}
wkord_sc3 = %{"workorder_template_id" => 3, "asset_id" => 1, "holidays" => [6,7], "first_occurrence_date" => "2022-02-15", "first_occurrence_time" => "09:00:00"}
wkord_sc4 = %{"workorder_template_id" => 4, "asset_id" => 1, "holidays" => [6,7], "first_occurrence_date" => "2022-02-15", "first_occurrence_time" => "09:00:00"}
wkord_sc5 = %{"workorder_template_id" => 5, "asset_id" => 1, "holidays" => [6,7], "first_occurrence_date" => "2022-02-15", "first_occurrence_time" => "09:00:00"}
wkord_sc6 = %{"workorder_template_id" => 6, "asset_id" => 1, "holidays" => [6,7], "first_occurrence_date" => "2022-02-15", "first_occurrence_time" => "09:00:00"}

{:ok, wkord_sc1c} = Workorder.create_workorder_schedule(wkord_sc1, "inc_bata")
{:ok, wkord_sc2c} = Workorder.create_workorder_schedule(wkord_sc2, "inc_bata")
{:ok, wkord_sc3c} = Workorder.create_workorder_schedule(wkord_sc3, "inc_bata")
{:ok, wkord_sc4c} = Workorder.create_workorder_schedule(wkord_sc4, "inc_bata")
{:ok, wkord_sc5c} = Workorder.create_workorder_schedule(wkord_sc5, "inc_bata")
{:ok, wkord_sc6c} = Workorder.create_workorder_schedule(wkord_sc6, "inc_bata")

# wk_ord1 = %{
#   "site_id" => 1,
#   "asset_id" => 1,
#   "user_id" => 1,
#   "type" => "BRK",
#   "scheduled_date" => "2021-09-14",
#   "scheduled_time" => "09:00:00",
#   "workorder_template_id" => 1,
#   "work_request_id" => 1
# }

wk_ord1 = %{
  "site_id" => 1,
  "asset_id" => 1,
  "asset_type" => "E",
  "user_id" => 1,
  "type" => "BRK",
  "scheduled_date" => "2021-09-14",
  "scheduled_time" => "09:00:00",
  "workorder_template_id" => 1,
  "work_request_id" => 1,
  "status" => "wpp",
  "workpermit_required_from" => [2]
}

wk_ord2 = %{
  "site_id" => 1,
  "asset_id" => 2,
  "user_id" => 1,
  "type" => "BRK",
  "scheduled_date" => "2021-09-15",
  "scheduled_time" => "09:00:00",
  "workorder_template_id" => 2,
  "work_request_id" => 1
}



wk_ord3 = %{
  "site_id" => 1,
  "asset_id" => 1,
  "user_id" => 1,
  "type" => "PRV",
  "scheduled_date" => "2021-09-14",
  "scheduled_time" => "09:00:00",
  "start_date" => "2021-12-22",
  "completed_date" => "2021-12-22",
  "workorder_template_id" => 1,
  "work_request_id" => 1,
  "workorder_schedule_id" => 1
}

wk_ord4 = %{
  "site_id" => 1,
  "asset_id" => 2,
  "user_id" => 1,
  "type" => "TKT",
  "start_date" => "2021-12-22",
  "completed_date" => "2021-12-22",
  "scheduled_date" => "2021-09-15",
  "scheduled_time" => "09:00:00",
  "workorder_template_id" => 2,
  "work_request_id" => 1,
  "workorder_schedule_id" => 1
}

{:ok, wk_ord1c} = Workorder.create_work_order(wk_ord1, "inc_bata", %{id: 1})
{:ok, wk_ord2c} = Workorder.create_work_order(wk_ord2, "inc_bata", %{id: 1})
{:ok, wk_ord3c} = Workorder.create_work_order(wk_ord3, "inc_bata", %{id: 1})
{:ok, wk_ord4c} = Workorder.create_work_order(wk_ord4, "inc_bata", %{id: 1})



wkreq_cat1 = %{"name" => "Electrical", "description" => "Deals with electrical work"}
wkreq_cat2 = %{"name" => "Mechanical", "description" => "Deals with mechanical work"}

{:ok, wkreq_cat1c} = Ticket.create_workrequest_category(wkreq_cat1, "inc_bata")
{:ok, wkreq_cat2c} = Ticket.create_workrequest_category(wkreq_cat2, "inc_bata")

wkreq_subcat1 = %{"name" => "Electrical Subcategory 1", "workrequest_category_id" => wkreq_cat1c.id, "response_tat" => 30, "resolution_tat" => 60}
wkreq_subcat2 = %{"name" => "Electrical Subcategory 2", "workrequest_category_id" => wkreq_cat1c.id, "response_tat" => 20, "resolution_tat" => 60}
wkreq_subcat3 = %{"name" => "Electrical Subcategory 3", "workrequest_category_id" => wkreq_cat1c.id, "response_tat" => 10, "resolution_tat" => 120}
wkreq_subcat4 = %{"name" => "Mechnical Subcategory 1", "workrequest_category_id" => wkreq_cat2c.id, "response_tat" => 15, "resolution_tat" => 50}
wkreq_subcat5 = %{"name" => "Mechnical Subcategory 2", "workrequest_category_id" => wkreq_cat2c.id, "response_tat" => 30, "resolution_tat" => 40}
wkreq_subcat6 = %{"name" => "Mechnical Subcategory 3", "workrequest_category_id" => wkreq_cat2c.id, "response_tat" => 10, "resolution_tat" => 60}

{:ok, wkreq_subcat1c} = Ticket.create_workrequest_subcategory(wkreq_subcat1, "inc_bata")
{:ok, wkreq_subcat2c} = Ticket.create_workrequest_subcategory(wkreq_subcat2, "inc_bata")
{:ok, wkreq_subcat3c} = Ticket.create_workrequest_subcategory(wkreq_subcat3, "inc_bata")
{:ok, wkreq_subcat4c} = Ticket.create_workrequest_subcategory(wkreq_subcat4, "inc_bata")
{:ok, wkreq_subcat5c} = Ticket.create_workrequest_subcategory(wkreq_subcat5, "inc_bata")
{:ok, wkreq_subcat6c} = Ticket.create_workrequest_subcategory(wkreq_subcat6, "inc_bata")

cat_help1 = %{
  "user_id" => 2,
  "site_id" => 1,
  "workrequest_category_id" => wkreq_cat1c.id
}

{:ok, cat_help1c} = Ticket.create_category_helpdesk(cat_help1, "inc_bata")

cat_help2 = %{
  "user_id" => 2,
  "site_id" => 1,
  "workrequest_category_id" => wkreq_cat2c.id
}

{:ok, cat_help2c} = Ticket.create_category_helpdesk(cat_help2, "inc_bata")

work_request1 = %{
  "site_id" => 1,
  "workrequest_subcategory_id" => wkreq_subcat1c.id,
  "description" => "Test",
  "priority" => "CR",
  "request_type" => "CO",
  "status" => "RS",
  "raised_date_time" => "2022-02-01 09:00:00",
  "location_id" => 1,
  "assigned_user_id" => 2
}

{:ok, work_request1c} = Ticket.create_work_request(work_request1, "inc_bata", %{id: 1})

work_request2 = %{
  "site_id" => 1,
  "workrequest_subcategory_id" => wkreq_subcat5c.id,
  "description" => "Test",
  "priority" => "CR",
  "request_type" => "RE",
  "is_approvals_required" => true,
  "approvals_required" => [1,2],
  "raised_date_time" => "2022-02-01 09:00:00",
  "status" => "RS",
  "location_id" => 1,
  "asset_id" => 1,
  "asset_type" => "E"
}

{:ok, work_request2c} = Ticket.create_work_request(work_request2, "inc_bata", %{id: 1})

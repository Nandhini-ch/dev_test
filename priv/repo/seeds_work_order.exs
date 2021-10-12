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
  "time_start" => nil,
  "time_end" => nil,
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
  "time_start" => nil,
  "time_end" => nil,
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
  "tasks" => [%{"id" => 3, "order" => 1}, %{"id" => 4, "order" => 2}],
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

{:ok, wkord_sc1c} = Workorder.create_workorder_schedule(wkord_sc1, "inc_bata")
{:ok, wkord_sc2c} = Workorder.create_workorder_schedule(wkord_sc2, "inc_bata")
{:ok, wkord_sc3c} = Workorder.create_workorder_schedule(wkord_sc3, "inc_bata")
{:ok, wkord_sc4c} = Workorder.create_workorder_schedule(wkord_sc4, "inc_bata")
{:ok, wkord_sc5c} = Workorder.create_workorder_schedule(wkord_sc5, "inc_bata")

wk_ord1 = %{
  "site_id" => 1,
  "asset_id" => 1,
  "user_id" => 1,
  "type" => "BRK",
  "scheduled_date" => "2021-09-14",
  "scheduled_time" => "09:00:00",
  "workorder_template_id" => 1,
  "work_request_id" => 1
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

{:ok, wk_ord1c} = Workorder.create_work_order(wk_ord1, "inc_bata", %{id: 1})
{:ok, wk_ord2c} = Workorder.create_work_order(wk_ord2, "inc_bata", %{id: 1})

wkord_tsk1 = %{
  "work_order_id" => 1,
  "task_id" => 1,
  "sequence" => 1,
  "response" => %{"label" => "abc", "value" => 30}
}

wkord_tsk2 = %{
  "work_order_id" => 1,
  "task_id" => 2,
  "sequence" => 2,
  "response" => %{"label" => "cde", "value" => 100}
}

{:ok, wkord_tsk1c} = Workorder.create_workorder_task(wkord_tsk1, "inc_bata")
{:ok, wkord_tsk2c} = Workorder.create_workorder_task(wkord_tsk2, "inc_bata")

wkreq_cat1 = %{"name" => "Electrical", "description" => "Deals with electrical work"}
wkreq_cat2 = %{"name" => "Mechanical", "description" => "Deals with mechanical work"}

{:ok, wkreq_cat1c} = Ticket.create_workrequest_category(wkreq_cat1, "inc_bata")
{:ok, wkreq_cat2c} = Ticket.create_workrequest_category(wkreq_cat2, "inc_bata")

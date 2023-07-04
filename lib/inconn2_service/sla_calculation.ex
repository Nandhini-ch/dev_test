defmodule Inconn2Service.SlaCalculation do
  import Ecto.Query, warn: false

  import Inconn2Service.Util.HelpersFunctions
  import Inconn2Service.Util.IndexQueries
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Assignment.Attendance
  alias Inconn2Service.Assignments.MasterRoster
  alias Inconn2Service.Assignments.Roster
  alias Inconn2Service.ContractManagement.ManpowerConfiguration
  alias Inconn2Service.Dashboards.NumericalData
  alias Inconn2Service.AssetConfig.{Location, Equipment}
  alias Inconn2Service.Ticket.WorkrequestSubcategory
  alias Inconn2Service.Ticket.WorkrequestStatusTrack
  alias Inconn2Service.Ticket.WorkRequest
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Workorder.WorkorderSchedule
  alias Inconn2Service.Repo
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.ContractManagement
  alias Inconn2Service.InventoryManagement.{Transaction, Store, Stock}

  def get_scope_details_from_contract(contract_id, prefix) do
    initial_map = %{site_ids: [], location_ids: [], asset_category_ids: []}

    scopes = ContractManagement.list_scopes_by_contract_id(contract_id, prefix)

    final_map =
      Enum.reduce(scopes, initial_map, fn scope, acc ->
        Map.put(acc, :site_ids, [scope.site_id] ++ acc.site_ids)
      end)

    final_map =
      Enum.reduce(scopes, final_map, fn scope, acc ->
        Map.put(acc, :location_ids, get_location_of_scope(scope, prefix) ++ acc.location_ids)
      end)

    Enum.reduce(scopes, final_map, fn scope, acc ->
      Map.put(
        acc,
        :asset_category_ids,
        get_asset_category_of_scope(scope, prefix) ++ acc.asset_category_ids
      )
    end)
  end

  defp get_location_of_scope(scope, prefix) do
    if scope.is_applicable_to_all_location do
      AssetConfig.list_location_ids_by_site_id(scope.site_id, prefix)
    else
      scope.location_ids
    end
  end

  defp get_asset_category_of_scope(scope, prefix) do
    if scope.is_applicable_to_all_asset_category do
      AssetConfig.list_asset_categories_ids(prefix)
    else
      scope.asset_category_ids
    end
  end

  def work_order_general_query(scope_map, from_date, to_date, _prefix) do
    from(wt in WorkorderTemplate,
      where: wt.asset_category_id in ^scope_map.asset_category_ids,
      join: wo in WorkOrder,
      on: wo.workorder_template_id == wt.id,
      where:
        wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and
          ^to_date >= wo.scheduled_end_date,
      select: %{
        workorder_template: wt,
        work_order: wo
      }
    )
  end

  # 1 status - MTBF
  def get_mtbf_status(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    from(e in Equipment,
      where:
        e.asset_category_id in ^scope_map.asset_category_ids and
          e.location_id in ^scope_map.location_ids and e.site_id in ^scope_map.site_ids,
      select: e.id
    )
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn e_id -> NumericalData.get_mtbf_of_equipment(e_id, from_dt, to_dt, prefix) end)
    |> Enum.sum()
  end

  # 2 Status - MTTR
  def get_mttr_status(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    from(e in Equipment,
      where:
        e.asset_category_id in ^scope_map.asset_category_ids and
          e.location_id in ^scope_map.location_ids and e.site_id in ^scope_map.site_ids,
      select: e.id
    )
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn e_id -> NumericalData.get_mttr_of_equipment(e_id, from_dt, to_dt, prefix) end)
    |> Enum.sum()
  end

  # 3 Movement completion in time %
  def movement_completion_in_time(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    wo_list =
      from(wt in WorkorderTemplate,
        where: wt.asset_category_id in ^scope_map.asset_category_ids and wt.movable,
        join: wo in WorkOrder,
        on:
          wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and
            ^to_date >= wo.scheduled_end_date,
        select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_in_time =
      Enum.count(wo_list, fn wo ->
        NaiveDateTime.compare(
          NaiveDateTime.new!(wo.completed_date, wo.completed_time),
          NaiveDateTime.new!(wo.scheduled_end_date, wo.scheduled_end_time)
        ) != :gt
      end)

    calculate_percentage(completed_in_time, Enum.count(wo_list))
  end

  # 4 Movement completion %
  def movement_completion(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    wo_list =
      from(wt in WorkorderTemplate,
        where: wt.asset_category_id in ^scope_map.asset_category_ids and wt.movable,
        join: wo in WorkOrder,
        on:
          wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and
            ^to_date >= wo.scheduled_end_date,
        select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_movable_work_order = Enum.count(wo_list, fn wo -> wo.status == "cp" end)

    calculate_percentage(completed_movable_work_order, Enum.count(wo_list))
  end

  # 5 Planned VS Completed
  def planned_vs_completed(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    wo_list =
      from(wt in WorkorderTemplate,
        where: wt.asset_category_id in ^scope_map.asset_category_ids,
        join: wo in WorkOrder,
        on:
          wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and
            ^to_date >= wo.scheduled_end_date,
        select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_in_work_order = Enum.count(wo_list, fn wo -> wo.status in "cp" end)

    calculate_percentage(completed_in_work_order, Enum.count(wo_list))
  end

  # 6 on time completion
  def on_time_completion(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    wo_list =
      from(wt in WorkorderTemplate,
        where: wt.asset_category_id in ^scope_map.asset_category_ids,
        join: wo in WorkOrder,
        on: wo.workorder_template_id == wt.id,
        where:
          wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and
            ^to_date >= wo.scheduled_end_date,
        select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_within_due_time =
      Enum.count(wo_list, fn wo ->
        NaiveDateTime.compare(
          NaiveDateTime.new!(wo.completed_date, wo.completed_time),
          NaiveDateTime.new!(wo.scheduled_end_date, wo.scheduled_end_time)
        ) != :gt
      end)

    calculate_percentage(completed_within_due_time, Enum.count(wo_list))
  end

  # 7 Manual WO completion ratio
  def manual_wo_completion_ratio(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    total_count_of_manual_work_orders =
      from(wt in WorkorderTemplate,
        where: wt.asset_category_id in ^scope_map.asset_category_ids,
        join: wo in WorkOrder,
        on:
          wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and
            ^to_date >= wo.scheduled_end_date and wo.type == "MAN",
        select: wo
      )
      |> Repo.all(prefix: prefix)

    count_of_completed_manual_work_orders =
      Enum.count(total_count_of_manual_work_orders, fn wo -> wo.status == "cp" end)

    calculate_percentage(
      count_of_completed_manual_work_orders,
      Enum.count(total_count_of_manual_work_orders)
    )
  end

  # 8 AMC schedule adherence

  def amc_schedule_adherence(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    total_count_of_amc_wo =
      from(wt in WorkorderTemplate,
        where: wt.asset_category_id in ^scope_map.asset_category_ids and wt.amc,
        join: wo in WorkOrder,
        on:
          wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and
            ^to_date >= wo.scheduled_end_date,
        select: wo
      )
      |> Repo.all(prefix: prefix)

    count_of_instances_executed_within_scheduled_date =
      Enum.count(total_count_of_amc_wo, fn wo ->
        NaiveDateTime.compare(
          NaiveDateTime.new!(wo.completed_date, wo.completed_time),
          NaiveDateTime.new!(wo.scheduled_end_date, wo.scheduled_end_time)
        ) != :gt
      end)

    calculate_percentage(
      count_of_instances_executed_within_scheduled_date,
      Enum.count(total_count_of_amc_wo)
    )
  end

  # 9 Planner
  def planner(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    count_of_assets_with_maintenance_planner_created =
      from(wt in WorkorderTemplate,
        where:
          wt.asset_category_id in ^scope_map.asset_category_ids and
            ^from_dt <= wt.applicable_start and ^to_dt >= wt.applicable_end,
        join: wos in WorkorderSchedule,
        on: wos.workorder_template_id == wt.id,
        select: wos
      )
      |> Repo.all(prefix: prefix)
      |> Enum.map(fn x -> "#{x.asset_id} #{x.asset_type}" end)
      |> Enum.uniq()

    eqp = equipment_query(Equipment, scope_map) |> Repo.all(prefix: prefix)
    loc = location_query(Location, scope_map) |> Repo.all(prefix: prefix)

    total_count = eqp ++ loc

    calculate_percentage(
      Enum.count(count_of_assets_with_maintenance_planner_created),
      Enum.count(total_count)
    )
  end

  # 10 Tools audit :- Manual

  # 11 MSL breach
  def msl_breach(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    # count_of_items_whose_stock_level_lesser_msl
    from(s in Store,
      where: s.site_id in ^scope_map.site_ids and s.location_id in ^scope_map.location_ids,
      join: t in Transaction,
      on: t.store_id == s.id,
      where:
        t.status == "CP" and t.is_minimum_stock_level_breached and
          ^from_date <= t.transaction_date and ^to_date >= t.transaction_date,
      select: t
    )
    |> Repo.all(prefix: prefix)
    |> Enum.count()
  end

  # 12 Zero stock level

  def zero_stock_level(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    # count_of_items_whose_stock_level_equal_to_zero
    from(s in Store,
      where: s.site_id in ^scope_map.site_ids and s.location_id in ^scope_map.location_ids,
      join: t in Transaction,
      on: t.store_id == s.id,
      where:
        t.status == "CP" and ^from_date <= t.transaction_date and ^to_date >= t.transaction_date,
      select: t
    )
    |> Repo.all(prefix: prefix)
    |> Enum.count(fn x -> x.total_stock - x.quantity == 0 end)
  end

  # 13 Shift coverage
  def shift_coverage(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    manpower_list =
      from(mr in MasterRoster,
        where: mr.site_id in ^scope_map.site_ids,
        join: r in Roster,
        on: r.master_roster_id == mr.id,
        where: ^from_dt <= r.date and ^to_dt >= r.date,
        select: r
      )
      |> Repo.all(prefix: prefix)

    count_of_manpower_present_in_shifts =
      from(at in Attendance,
        where:
          at.site_id in ^scope_map.site_ids and not is_nil(at.shift_id) and
            ^from_dt <= at.out_time and ^to_dt >= at.out_time
      )
      |> Repo.all(prefix: prefix)

    calculate_percentage(
      Enum.count(count_of_manpower_present_in_shifts),
      Enum.count(manpower_list)
    )
  end

  # 14 On time reporting
  def on_time_reporting(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    total_count_of_present =
      from(at in Attendance,
        where:
          at.site_id in ^scope_map.site_ids and not is_nil(at.shift_id) and
            ^from_dt <= at.out_time and ^to_dt >= at.out_time
      )
      |> Repo.all(prefix: prefix)

    count_of_manpower_within_time_config_limits =
      Enum.count(total_count_of_present, fn at -> at.status == "ONTM" end)

    calculate_percentage(
      count_of_manpower_within_time_config_limits,
      Enum.count(total_count_of_present)
    )
  end

  # 15 Shift continuation
  def shift_continuation(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    from(mr in MasterRoster,
      where: mr.site_id in ^scope_map.site_ids,
      join: r in Roster,
      on: r.master_roster_id == mr.id,
      where: ^from_dt <= r.date and ^to_dt >= r.date,
      select: r
    )
    |> Repo.all(prefix: prefix)
    |> Enum.group_by(&{&1.employee_id, &1.date})
    |> Enum.count(fn {_key, value} -> length(value) > 1 end)
  end

  # 16 Deployment status
  def deployment_status(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    count_of_manpower_rostered =
      from(mr in MasterRoster,
        where: mr.site_id in ^scope_map.site_ids,
        join: r in Roster,
        on: r.master_roster_id == mr.id,
        where: ^from_dt <= r.date and ^to_dt >= r.date,
        select: r
      )
      |> Repo.all(prefix: prefix)

    total_manpower_as_per_service_contract_setup =
      from(mp in ManpowerConfiguration,
        where: mp.site_id in ^scope_map.site_ids and mp.contract_id == ^contract_id
      )
      |> Repo.all(prefix: prefix)
      |> Enum.reduce(0, fn mpc, acc -> mpc.quantity + acc end)

    calculate_percentage(
      Enum.count(count_of_manpower_rostered),
      total_manpower_as_per_service_contract_setup
    )
  end

  # 17 Completion %
  def ticket_completion(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    ticket_list =
      from(wr in WorkRequest,
        where:
          wr.site_id in ^scope_map.site_ids and wr.location_id in ^scope_map.location_ids and
            ^from_dt <= wr.raised_date_time and ^to_dt >= wr.raised_date_time
      )
      |> Repo.all(prefix: prefix)

    count_of_tickets_with_status_closed = Enum.count(ticket_list, fn wr -> wr.status == "CS" end)

    calculate_percentage(count_of_tickets_with_status_closed, Enum.count(ticket_list))
  end

  # 18 TAT adherence - response
  def ticket_tat_response(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    ticket_list =
      from(wr in WorkRequest,
        where:
          wr.site_id in ^scope_map.site_ids and wr.location_id in ^scope_map.location_ids and
            ^from_dt <= wr.raised_date_time and ^to_dt >= wr.raised_date_time,
        join: wrs in WorkrequestSubcategory,
        on: wrs.id == wr.workrequest_subcategory_id,
        select: %{
          wr: wr,
          wrs: wrs
        }
      )
      |> Repo.all(prefix: prefix)

    count_of_tickets_assigned_status_within_time =
      Enum.filter(ticket_list, fn wr -> wr.response_tat != nil end)
      |> Enum.count(fn map -> map.response_tat <= map.response_tat end)

    calculate_percentage(count_of_tickets_assigned_status_within_time, Enum.count(ticket_list))
  end

  # 19 TAT adherence - resolution
  def ticket_tat_resolution(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    ticket_list =
      from(wr in WorkRequest,
        where:
          wr.site_id in ^scope_map.site_ids and wr.location_id in ^scope_map.location_ids and
            ^from_dt <= wr.raised_date_time and ^to_dt >= wr.raised_date_time,
        join: wrs in WorkrequestSubcategory,
        on: wrs.id == wr.workrequest_subcategory_id,
        select: %{
          wr: wr,
          wrs: wrs
        }
      )
      |> Repo.all(prefix: prefix)

    count_of_tickets_closed_status_within_time =
      Enum.filter(ticket_list, fn wr -> wr.resolution_tat != nil end)
      |> Enum.count(fn map -> map.resolution_tat <= map.resolution_tat end)

    calculate_percentage(count_of_tickets_closed_status_within_time, Enum.count(ticket_list))
  end

  # 20 Re-open %
  def ticket_reopen(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    # from_dt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    # to_dt = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from_dt = NaiveDateTime.from_iso8601!(from_date <> " 00:00:00")
    to_dt = NaiveDateTime.from_iso8601!(to_date <> " 23:59:59")

    ticket_list =
      from(wr in WorkRequest,
        where:
          wr.site_id in ^scope_map.site_ids and wr.location_id in ^scope_map.location_ids and
            ^from_dt <= wr.raised_date_time and ^to_dt >= wr.raised_date_time
      )
      |> Repo.all(prefix: prefix)

    count_of_ticket_reopen_status =
      from(wr in WorkRequest,
        where:
          wr.site_id in ^scope_map.site_ids and wr.location_id in ^scope_map.location_ids and
            ^from_dt <= wr.raised_date_time and ^to_dt >= wr.raised_date_time,
        join: wrst in WorkrequestStatusTrack,
        on: wrst.work_request_id == wr.id,
        where: wrst.status == "ROP",
        select: wrst
      )
      |> Repo.all(prefix: prefix)
      |> Enum.group_by(& &1.work_request_id)
      |> Enum.count()

    calculate_percentage(count_of_ticket_reopen_status, Enum.count(ticket_list))
  end
end

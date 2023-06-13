defmodule Inconn2Service.Report do
  import Ecto.Query, warn: false
  import Inconn2Service.Util.HelpersFunctions

  # alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.Repo
  alias Inconn2Service.{Account, AssetConfig}
  alias Inconn2Service.AssetConfig.{Equipment, Site}
  alias Inconn2Service.AssetConfig.AssetStatusTrack
  alias Inconn2Service.AssetConfig.Location
  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.Workorder.{WorkOrder, WorkorderTemplate, WorkorderStatusTrack, WorkorderTask, WorkorderSchedule}
  alias Inconn2Service.Workorder
  # alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.{WorkRequest, WorkrequestStatusTrack}
  alias Inconn2Service.Staff.{User, Employee, Designation, OrgUnit, Role, RoleProfile}
  alias Inconn2Service.{Inventory, Staff}
  alias Inconn2Service.Assignments.{Roster, MasterRoster}
  alias Inconn2Service.Assignment.Attendance
  alias Inconn2Service.InventoryManagement
  # alias Inconn2Service.Measurements.MeterReading
  # alias Inconn2Service.Inventory.{Item, InventoryLocation, InventoryStock, Supplier, UOM, InventoryTransaction}
  alias Inconn2Service.InventoryManagement.{Transaction, InventoryItem, Stock, Store, UnitOfMeasurement, InventorySupplier}

  def execution_data(prefix, query_params) do
    {workorders, filters} = work_order_execution_report(prefix, query_params)

    case query_params["task_type"] do
      "mt" ->
        work_order_execution_report_metering(workorders, filters, query_params, prefix)

      _ ->
        all_work_order_execution_report(workorders, filters, query_params, prefix)
    end
  end

  def work_order_execution_report(prefix, query_params) do
    query_params = rectify_query_params(query_params)
    filters = filter_data(query_params, prefix)
    main_query = from(wo in WorkOrder)

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"asset_type", asset_type}, main_query ->
          from q in main_query, where: q.asset_type == ^asset_type

        {"asset_id", asset_id}, main_query ->
          from q in main_query,
            where: q.asset_id == ^asset_id and q.asset_type == ^query_params["asset_type"]

        {"status", "incp"}, main_query ->
          from q in main_query, where: q.status not in ["cp", "cn"]

        {"status", status}, main_query ->
          from q in main_query, where: q.status == ^status

        {"user_id", user_id}, main_query ->
          from q in main_query, where: q.user_id == ^user_id

        _, main_query ->
          main_query
      end)

    {from_date, to_date} =
      get_dates_for_query(
        query_params["from_date"],
        query_params["to_date"],
        query_params["site_id"],
        prefix
      )

    query_with_dates =
      from(dq in dynamic_query,
        where: dq.scheduled_date >= ^from_date and dq.scheduled_date <= ^to_date
      )

    work_orders =
      Repo.all(query_with_dates, prefix: prefix)
      |> Stream.map(fn wo -> get_work_order_site(wo, prefix) end)
      |> Stream.map(fn wo -> put_asset_for_metering(wo, prefix) end)
      |> Enum.map(fn wo -> get_workorder_template_for_work_order(wo, prefix) end)
      |> filter_by_asset_categories(query_params["asset_category_id"])

    {work_orders, filters}
  end

  def work_order_execution_report_metering(workorders, filters, query_params, prefix) do
    report_headers = [
      "Date",
      "WO Number",
      "Asset Name",
      "Asset Code",
      "Measured Value",
      "Unit of measurement",
      "Within Range",
      "Done by"
    ]

    readings =
      Enum.reduce(workorders, [], fn wo, acc ->
        acc ++ get_metering_work_order_tasks(wo, prefix, query_params["uom"])
      end)
      |> Enum.map(fn wo -> put_done_by_in_readings(wo, prefix) end)
      |> Enum.sort_by(& &1.id, :desc)

    case query_params["type"] do
      "pdf" ->
        convert_to_pdf(
          "Work Order Execution Report for metering",
          filters,
          readings,
          report_headers,
          "WOEM"
        )

      "csv" ->
        csv_for_workorder_execution_metering(report_headers, readings)

      _ ->
        readings
    end
  end

  def all_work_order_execution_report(work_orders, filters, query_params, prefix) do
    readings =
      work_orders
      |> Enum.map(fn wo -> get_work_order_tasks(wo, prefix) end)
      |> Stream.map(fn wo -> put_done_by_type_name_and_range(wo, prefix) end)
      |> Enum.sort_by(& &1.id, :desc)

    case query_params["type"] do
      "pdf" ->
        convert_to_pdf("Work Order Execution Report", filters, readings, [], "WOE")

      "csv" ->
        csv_for_workorder_execution(readings)

      _ ->
        readings
    end
  end

  def put_done_by_type_name_and_range(wo, prefix) do
    range =
      if wo.scheduled_end_date != nil and wo.scheduled_end_time != nil do
        if Date.compare(wo.completed_date, wo.scheduled_end_date) in [:lt, :eq] &&
             Time.compare(wo.completed_time, wo.scheduled_end_time) in [:lt, :eq] do
          "In Time"
        else
          "Overdue"
        end
      else
        ""
      end

    Map.put(wo, :type_name, match_workorder_type(wo.type))
    |> Map.put(:range, range)
    |> put_done_by_in_readings(prefix)
  end

  defp get_from_and_to_date_time_in_report(from_date, to_date), do: {NaiveDateTime.new!(from_date, ~T[00:00:00]), NaiveDateTime.new!(to_date, ~T[23:59:59])}

  defp filter_by_asset_categories(work_orders, nil), do: work_orders
  defp filter_by_asset_categories(work_orders, asset_category_id), do: Enum.filter(work_orders, fn wo -> wo.workorder_template.asset_category_id == asset_category_id end)

  # defp filter_by_task_type(work_orders, "mt"), do: Stream.map(work_orders, fn wo -> Map.put(wo, :task_types, Enum.map(wo.tasks, fn t -> t.task.task_type end)) end) |> Enum.filter(fn wo -> "MT" in wo.task_types end)
  # defp filter_by_task_type(work_orders, _), do: work_orders

  defp get_work_order_site(wo, prefix) do
    Map.put(wo, :site, AssetConfig.get_site!(wo.site_id, prefix))
  end

  def put_done_by_in_readings(reading, prefix) do
    work_order = Workorder.get_work_order!(reading.id, prefix)
    user = Staff.get_user(work_order.user_id, prefix)
    Map.put(reading, :done_by, "#{user.first_name} #{user.last_name}")
  end

  def get_work_order_asset(wo, prefix) do
    case wo.asset_type do
      "E" -> Map.put(wo, :asset, AssetConfig.get_equipment!(wo.asset_id, prefix))
      "L" -> Map.put(wo, :asset, AssetConfig.get_location!(wo.asset_id, prefix))
    end
  end


  def put_asset_for_metering(wo, prefix) do
    case wo.asset_type do
      "E" ->
        equipment = AssetConfig.get_equipment!(wo.asset_id, prefix)
        Map.put(wo, :asset_name, equipment.name) |> Map.put(:asset_code, equipment.equipment_code)
      "L" ->
        location = AssetConfig.get_location!(wo.asset_id, prefix)
        Map.put(wo, :asset_name, location.name) |> Map.put(:asset_code, location.location_code)
    end
  end


  defp get_workorder_template_for_work_order(wo, prefix) do
    Map.put(wo, :workorder_template, Workorder.get_workorder_template!(wo.workorder_template_id, prefix))
  end

  defp get_work_order_tasks(wo, prefix) do
    work_order_tasks = Workorder.list_workorder_tasks(prefix, wo.id)
    |> Enum.map(fn wot -> Map.put(wot, :task, WorkOrderConfig.get_task!(wot.task_id, prefix)) end)
    Map.put(wo, :tasks, work_order_tasks)
  end

  defp get_metering_work_order_tasks(wo, prefix, uom) do
    Workorder.list_workorder_tasks(prefix, wo.id)
     |> Enum.map(fn wot ->
     task =  WorkOrderConfig.get_task!(wot.task_id, prefix)
     if(task.task_type == "MT" && task.config["UOM"] == uom)do
       Map.put(wot, :task, task)
     end
     end) |> Enum.filter(fn t -> t != nil end)
     |> Enum.map(fn d -> Map.put(wo, :metering_task, d) end)
   end

  def people_report(prefix, query_params) do
    report_headers = ["First Name", "Last Name", "Designation", "Department", "Employee Code", "Attendance Percentage", "Work Done Time"]
    filters = filter_data(query_params, prefix)
    result =
      people_report_query(query_params)
      |> Repo.all(prefix: prefix)
      # |> Stream.filter(fn x -> x.org_unit_id == query_params["org_unit_id"] end)
      |> Enum.map(fn x -> load_people_attendance_percent(x, query_params, prefix) end)

    summary = get_summary_of_people_report(result)
    summary_headers = ["Department", "Shift Coverage", "Work Done"]

    case query_params["type"] do
      "pdf" ->
        {convert_to_pdf("People Report", filters, result, report_headers, "PPL", summary, summary_headers), summary}

      "csv" ->
        {csv_for_people_report(report_headers, result, summary, summary_headers), summary}

      _ ->
        {result, summary}
    end
  end

  defp get_summary_of_people_report(result) do
    IO.inspect(result)
    |> Enum.group_by(&(&1.org_unit_id))
    |> Enum.map(fn {_k, list} ->
        [h | _t] = list
        %{
          department: h.department,
          shift_coverage: Enum.reduce(list, 0, fn m, acc -> m.attendance_percentage + acc end),
          work_done: Enum.reduce(list, 0, fn m, acc -> m.work_done_time_in_decimal + acc end) |> convert_man_hours_consumed()
        }
       end)
  end

  defp people_report_query(query_params) do
    query = people_report_dynamic_query(rectify_query_params(query_params))
    from(e in query,
          left_join: d in Designation, on: e.designation_id == d.id,
          left_join: o in OrgUnit, on: e.org_unit_id == o.id,
          join: u in User, on: u.employee_id == e.id,
          join: r in Role, on: u.role_id == r.id,
          join: rp in RoleProfile, on: r.role_profile_id == rp.id,
          select: %{
            first_name: e.first_name,
            last_name: e.last_name,
            employee_id: e.id,
            emp_code: e.employee_id,
            designation: d.name,
            department: o.name,
            org_unit_id: o.id,
            attendance_percentage: nil,
            work_done_time: nil
    })
  end

  defp load_people_attendance_percent(record, query_params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(query_params["from_date"], query_params["to_date"])
    {from_datetime, to_datetime} = get_from_and_to_date_time(query_params["from_date"], query_params["to_date"])
    expected_attendance_count =
      from(r in Roster, where: r.employee_id == ^record.employee_id and r.date >= ^from_date and r.date <= ^to_date,
          join: mr in MasterRoster, on: mr.id == r.master_roster_id,
          select: %{
            site_id: mr.site_id,
            shift_id: r.shift_id,
            date: r.date
      })
      |> Repo.all(prefix: prefix)
      |> Enum.count()

    actual_attendance =
      from(a in Attendance, where: a.employee_id == ^record.employee_id and a.in_time >= ^from_datetime and a.in_time <= ^to_datetime)
      |> Repo.all(prefix: prefix)

      work_done_time =
            Stream.map(actual_attendance, fn at ->
                if at.out_time != nil do
                  NaiveDateTime.diff(at.out_time, at.in_time)
                else
                  0
                end
              end)
            |> Enum.sum()

    Map.put(record, :attendance_percentage, div(length(actual_attendance), change_nil_to_one(expected_attendance_count)) * 100)
    |> Map.put(:work_done_time, convert_man_hours_consumed(work_done_time))
    |> Map.put(:work_done_time_in_decimal, work_done_time)

  end

  defp people_report_dynamic_query(query_params) do
    query = from(e in Employee)
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      {"asset_category_id", asset_category_id}, query -> from q in query, where: ^asset_category_id in q.skills
      _,  query -> query
    end)
  end

  def work_status_report(prefix, query_params) do
    query_params = rectify_query_params(query_params)

    query_params =
      query_params
      |> Map.put("asset_ids", AssetConfig.get_loc_and_eqp_subtree_ids(query_params["asset_id"], query_params["asset_type"], prefix))

    IO.inspect(query_params)

    main_query =
      from wo in WorkOrder,
      left_join: u in User, on: wo.user_id == u.id,
      left_join: e in Employee, on: u.employee_id == e.id,
      left_join: s in Site, on: wo.site_id == s.id,
      select: %{
        id: wo.id,
        site_id: wo.site_id,
        site: s,
        asset_id: wo.asset_id,
        asset_type: wo.asset_type,
        type: wo.type,
        status: wo.status,
        assigned_to: e.first_name,
        start_date: wo.start_date,
        start_time: wo.start_time,
        completed_date: wo.completed_date,
        completed_time: wo.completed_time,
        username: u.username,
        first_name: e.first_name,
        last_name: e.last_name,
        scheduled_date: wo.scheduled_date,
        scheduled_time: wo.scheduled_time,
        workorder_template_id: wo.workorder_template_id
      }


    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"asset_type", asset_type}, main_query ->
          from q in main_query, where: q.asset_type == ^asset_type

        {"asset_ids", []}, main_query -> main_query

        {"asset_ids", asset_ids}, main_query ->
          from q in main_query, where: q.asset_id in ^asset_ids and q.asset_type == ^query_params["asset_type"]

        {"status", "incp"}, main_query ->
          from q in main_query, where: q.status not in ["cp", "cn"]

        {"status", status}, main_query ->
          from q in main_query, where: q.status == ^status

        {"user_id", user_id}, main_query ->
          from q in main_query, where: q.user_id == ^user_id

        _, main_query ->
          main_query
      end)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)

    query_with_dates = from dq in dynamic_query, where: dq.scheduled_date >= ^from_date and dq.scheduled_date <= ^to_date


    work_orders = Repo.all(query_with_dates, prefix: prefix)

    work_orders_with_asset =
      Enum.map(work_orders, fn work_order ->
        asset =
          case work_order.asset_type do
            "E" -> AssetConfig.get_equipment!(work_order.asset_id, prefix)
            "L" -> AssetConfig.get_location!(work_order.asset_id, prefix)
            _ ->
              get_asset_from_workorder_template(work_order, prefix)

          end
        Map.put_new(work_order, :asset, asset)
      end)

    # IO.inspect(List.first(work_orders_with_asset))

    result =
      Enum.map(work_orders_with_asset, fn wo ->
        asset_type = get_asset_type_from_workorder_template(wo, prefix)
        {asset_name, asset_code} =
          case asset_type do
            "E" ->
              {wo.asset.name, wo.asset.equipment_code}

            "L" ->
              {wo.asset.name, wo.asset.location_code}
          end

        name =
          if is_nil(wo.first_name), do: wo.username, else: wo.first_name

        manhours_consumed =
          cond do
            is_nil(wo.start_time) || is_nil(wo.start_date) ->
              0

            is_nil(wo.completed_time) || is_nil(wo.completed_date) ->
              Time.diff(get_site_date_time(wo.site), NaiveDateTime.new!(wo.start_date, wo.start_time)) |> convert_to_positive()

            true ->
              # Time.diff(wo.completed_time, wo.start_time)
              Time.diff(NaiveDateTime.new!(wo.completed_date, wo.completed_time), NaiveDateTime.new!(wo.start_date, wo.start_time)) |> convert_to_positive()
          end

        %{
          id: wo.id,
          site_id: wo.site_id,
          asset_name: asset_name,
          asset_code: asset_code,
          type: match_workorder_type(wo.type),
          status: wo.status,
          workorder_template_id: wo.workorder_template_id,
          assigned_to: name,
          manhours_consumed: convert_man_hours_consumed(manhours_consumed),
          scheduled_date: wo.scheduled_date,
          scheduled_time: wo.scheduled_time,
          converted_scheduled_date: convert_date_format(wo.scheduled_date),
          converted_scheduled_time: convert_time_format(wo.scheduled_time),
          start_date: convert_date_format(wo.start_date),
          start_time: convert_time_format(wo.start_time),
          completed_date: convert_date_format(wo.completed_date),
          completed_time: convert_time_format(wo.completed_time)
        }
      end)

    report_headers = ["Id", "Asset Name", "Asset Code", "Type", "Status", "Assigned To", "Scheduled Date", "Scheduled Time", "Start Date", "Start Time", "Completed Date", "Completed Time", "Manhours Consumed"]

    filters = filter_data(query_params, prefix)

    summary = get_summary_of_maintainance(result, prefix)

    summary_headers = ["Asset Category", "Count of Assets", "Total WO", "Completed WO", "Pending WO", "Overdue"]

    case query_params["type"] do
      "pdf" ->
        {convert_to_pdf("Work Order Report", filters, result, report_headers, "WO", summary, summary_headers), summary}

      "csv" ->
        {csv_for_workorder_report(report_headers, result, summary, summary_headers), summary}

      _ ->
        {result, summary}
    end
  end

  def get_summary_of_maintainance(result, prefix) do
    result
    |> Enum.map(fn wo ->
      workorder_template = Inconn2Service.Workorder.get_workorder_template(wo.workorder_template_id, prefix)
      Map.put(wo, :asset_category_id, workorder_template.asset_category_id)
      |> Map.put(:asset_category, Inconn2Service.AssetConfig.get_asset_category!(workorder_template.asset_category_id, prefix)
      |> Map.put(:estimated_time, workorder_template.estimated_time))
    end)
    |> Enum.group_by(&(&1.asset_category_id))
    |> Enum.map(fn {_k, v} ->
      total_workorder = length(v)
      completed_workorder = Enum.filter(v, fn a -> a.status == "cp" end) |> Enum.count()
      pending_workorder = total_workorder - completed_workorder
      asset_category = List.first(v).asset_category
      %{
        asset_category: asset_category.name,
        count_of_assets: AssetConfig.get_asset_count_by_asset_category(asset_category.id, asset_category.asset_type, prefix),
        total_workorder: length(v),
        completed_workorder: "Completed Workorder: #{completed_workorder}",
        pending_workorder: "Pending Workorder: #{pending_workorder}",
        overdue_percentage: "#{calculate_overdue(v, prefix)} %"
      }
    end)
  end

  def calculate_overdue(wo_list, prefix) do
    pending_list = Enum.filter(wo_list, fn a -> a.status != "cp" end)
    overdue_count =
      Enum.map(pending_list, fn wo -> Workorder.add_overdue_flag(wo, prefix) end)
     |> Enum.count(fn wo -> wo.overdue end)
    calculate_percentage(overdue_count, length(pending_list))
  end

  defp convert_to_positive(number) do
    cond do
      number < 0 -> number * -1.0
      true -> number
    end
  end

  def convert_man_hours_consumed(nil) do
    nil
  end

  def convert_man_hours_consumed(manhours_consumed) do
    time = to_string(manhours_consumed/3600 |> Float.ceil(2)) |> String.split(".")
    hour = List.first(time)
    float_string = "0." <> List.last(time)
    minute = String.to_float(float_string) *60 |> Float.ceil() |> Kernel.trunc()  |> Integer.to_string()
    hour_and_minute(hour) <> ":" <> hour_and_minute(minute)
  end

  def convert_time_taken_to_close(nil) do
    nil
  end

  def convert_time_taken_to_close(manhours_consumed) do
    time = to_string(manhours_consumed/60) |> String.split(".")
    hour = List.first(time)
    float_string = "0." <> List.last(time)
    minute = String.to_float(float_string) *60 |> Float.ceil() |> Kernel.trunc()  |> Integer.to_string()
    hour_and_minute(hour) <> ":" <> hour_and_minute(minute)
  end

  defp hour_and_minute(t) do
    case String.length(t) do
      1 -> "0" <> t
      _ -> t
    end
 end


  defp get_site_date_time(site) do
    date_time = DateTime.now!(site.time_zone)
    NaiveDateTime.new!(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.minute, date_time.second)
  end

  def inventory_report(prefix, query_params) do
    rectified_query_params = rectify_query_params(query_params)
    query = inventory_report_query()
    headers = ["Date", "Name", "Type", "Store", "Transaction Type", "Quantity", "Reorder Level", "UOM", "Aisle", "Row", "Bin", "Cost", "Supplier"]
    query_with_params =
      Enum.reduce(rectified_query_params, query, fn
        {"transaction_type", ""}, query -> query
        {"transaction_type", transaction_type}, query -> from q in query, where: q.transaction_type == ^transaction_type
        {"item_id", item_id}, query -> from q in query, where: q.inventory_item_id == ^item_id
        {"store_id", store_id}, query -> from q in query, where: q.store_id == ^store_id
        _, query -> query
      end)

    {from_date, to_date} = get_dates_for_query(rectified_query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    date_applied_query = from q in query_with_params, where: q.transaction_date >= ^from_date and q.transaction_date <= ^to_date

    IO.inspect(Repo.all(date_applied_query, prefix: prefix))

    result =
      Repo.all(date_applied_query, prefix: prefix)
      |> filter_by_site(rectified_query_params["site_id"])
      |> filter_by_asset_category(rectified_query_params["asset_category_id"], prefix)

    summary_headers =["Store Location", "Count of Receive Transactions", "Count of Issue Transactions","MSL Breach Item Count"]

    summary = summary_for_inventory_report(result, prefix)

    filters = filter_data(query_params, prefix)

    case query_params["type"] do
      "pdf" ->
        {convert_to_pdf("Inventory Report", filters, result, headers, "IN", summary, summary_headers), summary}

      "csv" ->
        {csv_for_inventory_report(headers, result, summary, summary_headers), summary}

      _ ->
        {result, summary}
    end
  end

  def summary_for_inventory_report(result, prefix) do
    Enum.group_by(result, &(&1.store_id))
    |> Enum.map(fn {_k, v} ->
      store_id = List.first(v).store_id
      %{
        store_location: InventoryManagement.get_store!(store_id, prefix).name,
        count_of_receive: Enum.filter(v, fn a -> a.transaction_type in ["IN"] end) |> Enum.count(),
        count_of_issue: Enum.filter(v, fn a -> a.transaction_type in ["IS"] end) |> Enum.count(),
        msl_breach_count: msl_breach_count_for_store(store_id, prefix)
      }
    end)
  end

  def msl_breach_count_for_store(store_id, prefix) do
    from(st in Stock, where: st.store_id == ^store_id,
    join: i in InventoryItem, on: i.id == st.inventory_item_id,
    select: %{
      quantity: st.quantity,
      minimum_stock_level: i.minimum_stock_level,
      item_id: i.id
    })
    |> Repo.all(prefix: prefix)
    |> Enum.group_by(&(&1.item_id))
    |> Enum.map(fn {_k, item_list} ->
        quantity = Enum.reduce(item_list, 0, fn item, acc -> acc + item.quantity end)
        quantity < List.first(item_list).minimum_stock_level
    end)
    |> Enum.count(fn boolean -> boolean end)
  end

  def filter_by_site(list, nil), do: list
  def filter_by_site(list, site_id), do: Enum.filter(list, fn x -> x.site_id == String.to_integer(site_id) end)

  def filter_by_asset_category(list, nil, _prefix), do: list
  def filter_by_asset_category(list, asset_category_id, prefix) do
    asset_category_ids = AssetConfig.get_asset_category_subtree_ids(asset_category_id, prefix)
    Enum.filter(list, fn x -> Enum.any?(asset_category_ids, &Enum.member?(x.asset_category_ids, &1)) end)
  end

  defp inventory_report_query() do
    from t in Transaction,
      left_join: i in InventoryItem, on: i.id == t.inventory_item_id,
      left_join: st in Stock, on: st.inventory_item_id == i.id and st.store_id == t.store_id,
      left_join: u in UnitOfMeasurement, on: u.id == t.unit_of_measurement_id,
      left_join: s in Store, on: s.id == t.store_id,
      left_join: su in InventorySupplier, on: su.id == t.inventory_supplier_id,
      select: %{
        date: t.transaction_date,
        item_name: i.name,
        item_type: i.item_type,
        store_name: s.name,
        store_id: s.id,
        site_id: s.site_id,
        reorder_level: i.minimum_stock_level,
        transaction_type: t.transaction_type,
        transaction_quantity: t.quantity,
        asset_category_ids: i.asset_category_ids,
        uom: u.name,
        aisle: t.aisle,
        bin: t.bin,
        row: t.row,
        cost: t.cost,
        supplier: su.name,
        status: t.status
      }
  end

  def work_request_report(prefix, query_params) do
    query_params = rectify_query_params(query_params)

    main_query = from wo in WorkRequest

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"status", "closed"}, main_query ->
          from q in main_query, where: q.status in ["CS", "CP"]

        {"status", "not-closed"}, main_query ->
          from q in main_query, where: q.status in ["RS", "AP", "AS"]

        {"status", "rejected"}, main_query ->
          from q in main_query, where: q.status in ["RJ", "CL"]

        {"status", "reopened"}, main_query ->
          from q in main_query, where: q.status in ["ROP"]

        {"asset_type", asset_type}, main_query ->
          from q in main_query, where: q.asset_type == ^asset_type

        {"asset_id", asset_id}, main_query ->
          from q in main_query, where: q.asset_id == ^asset_id and q.asset_type == ^query_params["asset_type"]

        {"workrequest_category_id", workrequest_category_id}, main_query ->
          from q in main_query, where: q.workrequest_category_id == ^workrequest_category_id

        {"assigned_user_id", assigned_user_id}, main_query ->
          from q in main_query, where: q.assigned_user_id == ^assigned_user_id

        _, main_query ->
          main_query

      end)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    naive_from_date = convert_date_to_naive_date_time(from_date,  "from")
    naive_to_date = convert_date_to_naive_date_time(to_date, "to")

    IO.inspect(naive_from_date)
    IO.inspect(naive_to_date)

    query_with_dates = from dq in dynamic_query, where: dq.raised_date_time > ^naive_from_date and dq.raised_date_time < ^naive_to_date


    work_requests =
      Repo.all(query_with_dates, prefix: prefix)
      |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])

    work_requests_with_asset =
      Enum.map(work_requests, fn work_request ->
        asset =
          # case work_request.asset_type do
          #   "E" -> AssetConfig.get_equipment(work_request.asset_id, prefix)
          #   "L" -> AssetConfig.get_location(work_request.asset_id, prefix)
          #   _ -> nil
          # end

          cond do
            work_request.asset_type == "E" && !is_nil(work_request.asset_id) ->
              AssetConfig.get_equipment(work_request.asset_id, prefix)

            work_request.asset_type == "L" && !is_nil(work_request.asset_id) ->
              AssetConfig.get_location(work_request.asset_id, prefix)

            true ->
              nil
          end
          Map.put_new(work_request, :asset, asset)
      end)

    result =
      Enum.map(work_requests_with_asset, fn wr ->

        asset_name =
          if wr.asset != nil do
            wr.asset.name
          else
            nil
          end

        asset_category =
          if wr.asset != nil do
            IO.inspect(wr.asset)
            AssetConfig.get_asset_category!(wr.asset.asset_category_id, prefix).name
          else
            nil
          end

        raised_by =
          cond do
            wr.is_external_ticket && !is_nil(wr.external_name) ->
              wr.external_name

            wr.requested_user != nil && wr.requested_user.employee != nil ->
              wr.requested_user.employee.first_name <> " " <> wr.requested_user.employee.last_name

            wr.requested_user != nil ->
              wr.requested_user.username

            true ->
              nil
          end


          assigned_to =
            cond do
              wr.assigned_user != nil && wr.assigned_user.employee != nil ->
                wr.assigned_user.employee.first_name <> " " <> wr.assigned_user.employee.last_name

              wr.assigned_user != nil ->
                wr.assigned_user.username

              true ->
                nil
            end

        workrequest_sub_category =
          if wr.workrequest_subcategory != nil do
            # Ticket.get_workrequest_subcategory!(wr.workrequest_subcategory_id, prefix)
            wr.workrequest_subcategory
          else
            nil
          end

        {ticket_response_tat, ticket_resolution_tat} =
          if workrequest_sub_category != nil do
            {workrequest_sub_category.response_tat, workrequest_sub_category.resolution_tat}
          else
            {nil, nil}
          end

          response_tat_met = check_response_tat(ticket_response_tat, wr.response_tat)
          resolution_tat_met = check_resolution_tat(ticket_resolution_tat, wr.resolution_tat)

        # {response_tat_met, resolution_tat_met} =
        #   if ticket_response_tat != nil && wr.response_tat != nil || ticket_resolution_tat != nil &&  wr.resolution_tat != nil do
        #     cond do
        #       wr.response_tat <= ticket_response_tat &&  wr.resolution_tat <= ticket_resolution_tat  ->
        #         {"Yes", "Yes"}

        #         wr.response_tat <= ticket_response_tat ->
        #         {"Yes", nil}

        #       true ->
        #         {"No", "No"}
        #     end
        #   else
        #     {nil, nil}
        #   end

        time_taken_to_close =
          if wr.resolution_tat != nil do
            wr.resolution_tat
          else
            nil
          end

        workrequest_category =
          if wr.workrequest_category != nil do
            wr.workrequest_category.name
          else
            nil
          end

        %{
          workrequest_category_id: wr.workrequest_category_id,
          asset_name: asset_name,
          asset_category: asset_category,
          ticket_type: (if wr.is_external_ticket do "External" else "Internal" end),
          ticket_category: workrequest_category,
          ticket_subcategory: workrequest_sub_category.name,
          description: wr.description,
          raised_by: raised_by,
          assigned_to: assigned_to,
          response_tat: response_tat_met,
          resolution_tat: resolution_tat_met,
          backend_status: wr.status,
          status: match_work_request_status(wr.status),
          time_taken_to_close: convert_time_taken_to_close(time_taken_to_close),
          date: "#{wr.raised_date_time.day}-#{wr.raised_date_time.month}-#{wr.raised_date_time.year}",
          time: "#{wr.raised_date_time.hour}:#{wr.raised_date_time.minute}"
        }
      end)

    report_headers = ["Asset Name", "Date", "Time", "Ticket Type", "Ticket Category", "Ticket Subcategory", "Description", "Raised By", "Assigned To", "Response TAT", "Resolution TAT", "Status", "Time Taken to Complete"]
    summary_headers =["Ticket Category", "Count of tickets", "Resolved Count", "Open Count"]

    filters = filter_data(query_params, prefix)

    summary = summary_for_workrequest_report(result)


    case query_params["type"] do
      "pdf" ->
        {convert_to_pdf("Ticket Report", filters, result, report_headers, "WR", summary, summary_headers), summary}

      "csv" ->
        {csv_for_workrequest_report(report_headers, result, summary, summary_headers), summary}

      _ ->
        {result, summary}
    end
  end

  defp check_resolution_tat(expected_resolution_tat, actual_resolution_tat) when not is_nil(expected_resolution_tat) and not is_nil(actual_resolution_tat) do
    if actual_resolution_tat <= expected_resolution_tat do
      "Yes"
    else
      "No"
    end
  end
  defp check_resolution_tat(_expected_resolution_tat, _actual_resolution_tat), do: "-"

  defp check_response_tat(expected_response_tat, actual_response_tat) when not is_nil(expected_response_tat) and not is_nil(actual_response_tat) do
    if actual_response_tat <= expected_response_tat do
      "Yes"
    else
      "No"
    end
  end
  defp check_response_tat(_expected_response_tat, _actual_response_tat), do: "-"

  defp calculate_times_from_minutes(minutes) do
    [hours, rest] = get_hours(minutes)
    minutes = get_minutes(rest)
    "#{hours}:#{minutes}"
  end

  defp get_hours(minutes) do
    div(minutes, 60)
    |> Float.to_string()
    |> String.split(".")
  end

  defp get_minutes(minutes) do
    {number, _} = Float.parse(minutes)
    number * 60
  end

  def summary_for_workrequest_report(result) do
    Enum.group_by(result, &(&1.workrequest_category_id))
    |> Enum.map(fn {_k, v} ->
      %{
        ticket_category: List.first(v).ticket_category,
        count: Enum.count(v),
        resolved_count: Enum.count(v, fn a -> a.backend_status in ["CL", "CP", "CS"] end),
        open_count: Enum.count(v, fn a -> a.backend_status not in ["CL", "CP", "CS"] end)
      }
    end)
  end

  def asset_status_report(prefix, query_params) do
    query_params = rectify_query_params(query_params)

    query_params =
      query_params
      |> Map.put("asset_category_ids", AssetConfig.get_asset_category_subtree_ids(query_params["asset_category_id"], prefix))
      |> Map.put("location_ids", AssetConfig.get_location_subtree_ids(query_params["location_id"], prefix))

    equipments_data = get_equipment_details(prefix, query_params)
    locations_data = get_location_details(prefix, query_params)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)

    report_headers = ["Asset Name", "Asset Code", "Asset Category", "Asset Type", "Status", "Criticality", "Up Time", "Utilized Time", "PPM Completion Percentage"]

    filters = filter_data(query_params, prefix)

    summary_headers = ["Asset Category", "Count of Assets", "Count by Status", "PPM Completion %"]

    summary = get_summary_of_assets(equipments_data ++ locations_data, prefix, from_date, to_date, query_params)

    case query_params["type"] do
      "pdf" ->
        {convert_to_pdf("Asset Status Report", filters, equipments_data ++ locations_data, report_headers, "AST", summary, summary_headers), summary}

      "csv" ->
        {csv_for_asset_status_report(report_headers, equipments_data ++ locations_data, summary, summary_headers), summary}

      _ ->
        {equipments_data ++ locations_data, summary}
    end

  end

  def get_summary_of_assets(result, prefix, from_date, to_date, query_params) do
    result
    |> Enum.group_by(&(&1.asset_category_id))
    |> Enum.map(fn {k, v} ->
      count = length(v)
      available_assets = Enum.filter(v, fn a -> a.status in ["ON", "OFF"] end) |> Enum.count()
      break_down_assets = count - available_assets
      %{
        asset_category: List.first(v).asset_category,
        count: length(v),
        count_by_status: "Available: #{available_assets}, Not_available: #{break_down_assets}",
        ppm_completion: get_ppm_compliance_for_asset_category(k, from_date, to_date, query_params, prefix)
      }
    end)
  end

  defp get_ppm_compliance_for_asset_category(asset_category_id, from_date, to_date, query_params, prefix) do
    work_orders =
      from(wot in WorkorderTemplate, where: wot.asset_category_id == ^asset_category_id,
      join: wo in WorkOrder, on: wo.workorder_template_id == wot.id and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date,
      select: wo)
      |> Repo.all(prefix: prefix)
      |> filter_wo_by_site(query_params["site_id"])

    completed_workorders = Enum.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()

    get_calculated_compliance_value(length(work_orders), completed_workorders)
  end

  defp get_calculated_compliance_value(0, _), do: "0" <> "%"
  defp get_calculated_compliance_value(total, completed), do: completed/total * 100 |> Float.ceil(2) |> to_string |> Kernel.<>("%")

  defp filter_wo_by_site(work_orders, nil), do: work_orders
  defp filter_wo_by_site(work_orders, site_id), do: Enum.filter(work_orders, fn wo -> wo.site_id == site_id end)

  defp get_equipment_details(prefix, query_params) do
    main_query = from e in Equipment

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"location_ids", []}, main_query ->
          main_query

        {"location_ids", location_ids}, main_query ->
          from q in main_query, where: q.location_id in ^location_ids

        {"status", status}, main_query ->
          from q in main_query, where: q.status == ^status

        {"asset_category_ids", []}, main_query ->
          main_query

        {"asset_category_ids", asset_category_ids}, main_query ->
          from q in main_query, where: q.asset_category_id in ^asset_category_ids

        _ , main_query ->
          main_query
      end)


    equipments = Repo.all(dynamic_query, prefix: prefix)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    naive_from_date = convert_date_to_naive_date_time(from_date, "from")
    naive_to_date = convert_date_to_naive_date_time(to_date, "to")

    IO.inspect(naive_from_date)
    IO.inspect(naive_to_date)

    Enum.map(equipments, fn e ->
      asset_status_tracks =
        from(ast in AssetStatusTrack, where: ast.asset_id == ^e.id and ast.asset_type == ^"E" and ast.changed_date_time >= ^naive_from_date and ast.changed_date_time <= ^naive_to_date)
        |> Repo.all(prefix: prefix)

      up_time =
        case length(asset_status_tracks) do
          0 ->
            last_entry = get_last_entry_previous(e.id, "E", naive_from_date, prefix)
            if last_entry != nil and last_entry.status_changed in ["ON", "OFF"] do
              NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time) / 3600 |> convert_to_positive() |> convert_man_hours_consumed()
            else
              0.0
            end

          _ ->
            last_entry = List.last(asset_status_tracks)
            compensation_hours =
              if last_entry.status_changed in ["ON", "OFF"] do
                NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time) / 3600
              else
                0.0
              end
            sum =
              Stream.filter(asset_status_tracks, fn ast -> ast.status_changed in ["ON", "OFF"] end)
              |> Stream.map(fn ast -> ast.hours end)
              |> Stream.filter(fn h -> !is_nil(h) end)
              |> Enum.sum()

            sum + compensation_hours * 1.0
            |> Float.ceil(2)
            |> convert_man_hours_consumed()
        end


        utilized_time =
          case length(asset_status_tracks) do
            0 ->
              # IO.inspect("-----------wqe4342")
              last_entry = get_last_entry_previous(e.id, "E", naive_from_date, prefix)
              if last_entry != nil and last_entry.status_changed == "ON" do
                NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time) |> convert_to_positive() |> convert_man_hours_consumed()
                0.0
              end

            _ ->
              last_entry = List.last(asset_status_tracks)
              compensation_hours =
                if last_entry.status_changed in ["ON", "OFF"] do
                  IO.inspect(NaiveDateTime.diff(last_entry.changed_date_time, NaiveDateTime.new!(to_date, Time.new!(0,0,0))) / 3600)
                  NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time) |> convert_to_positive()
                else
                  # IO.inspect("213123")
                  0.0
                end
              sum =
                Enum.filter(asset_status_tracks, fn ast -> ast.status_changed in ["ON"] end)
                |> Enum.map(fn ast -> ast.hours end)
                |> Stream.filter(fn h -> !is_nil(h) end)
                |> Enum.sum()

              sum + compensation_hours * 1.0
              |> Float.ceil(2)
              |> convert_man_hours_consumed()
          end

      # up_time =
      #   Enum.filter(asset_status_tracks, fn ast -> ast.status in ["ON", "OFF"] end)
      #   |> Enum.map(fn ast -> ast.hours end)
      #   |> Enum.sum()

      # utilized_time =
      #   Enum.filter(asset_status_tracks, fn ast -> ast.status in ["ON"] end)
      #   |> Enum.map(fn ast -> ast.hours end)
      #   |> Enum.sum()

      ppm_work_orders =
        (from wo in WorkOrder, where: wo.asset_id == ^e.id and wo.asset_type == ^"E" and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date)
        |> Repo.all(prefix: prefix)

      completed_ppm = Enum.filter(ppm_work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()

      # IO.inspect("Actual length: #{length(ppm_work_orders)}")
      # IO.inspect("Completed: #{completed_ppm}")

      completion_percentage =
        if length(ppm_work_orders) != 0 do
          # IO.inspect("Dsadfsdgredfcvsgefd")
          (completed_ppm/length(ppm_work_orders)) * 100.00
        else
          0.0
        end

      %{
        asset_name: e.name,
        asset_code: e.equipment_code,
        asset_type: "Equipment",
        asset_category_id: e.asset_category_id,
        asset_category: AssetConfig.get_asset_category!(e.asset_category_id, prefix).name,
        status: e.status,
        criticality: (if e.criticality <= 2, do: "Critical", else: "Not Critical"),
        up_time: up_time,
        utilized_time: utilized_time,
        ppm_completion_percentage: Float.ceil(completion_percentage, 2) |> to_string |> Kernel.<>("%")
      }
    end)
  end

  defp get_location_details(prefix, query_params) do
    main_query = from l in Location

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"location_id", []}, main_query ->
          main_query

        {"location_ids", location_ids}, main_query ->
          from q in main_query, where: q.id in ^location_ids

        {"status", status}, main_query ->
          from q in main_query, where: q.status == ^status

        {"asset_category_ids", []}, main_query ->
          main_query

        {"asset_category_ids", asset_category_ids}, main_query ->
          from q in main_query, where: q.asset_category_id in ^asset_category_ids

        _ , main_query ->
          main_query
      end)


    locations = Repo.all(dynamic_query, prefix: prefix)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    naive_from_date = convert_date_to_naive_date_time(from_date, "from")
    naive_to_date = convert_date_to_naive_date_time(to_date, "to")

    IO.inspect(naive_from_date)
    IO.inspect(naive_to_date)

    Enum.map(locations, fn l ->
      asset_status_tracks =
        from(ast in AssetStatusTrack, where: ast.asset_id == ^l.id and ast.asset_type == ^"L" and ast.changed_date_time >= ^naive_from_date and ast.changed_date_time <= ^naive_to_date)
        |> Repo.all(prefix: prefix)

      up_time =
        case length(asset_status_tracks) do
          0 ->
            last_entry = get_last_entry_previous(l.id, "L", naive_from_date, prefix)
            if last_entry != nil and last_entry.status_changed in ["ON", "OFF"] do
              NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time)  |> convert_to_positive() |> convert_man_hours_consumed()
            else
              0.0
            end

          _ ->
            last_entry = List.last(asset_status_tracks)
            compensation_hours =
              if last_entry.status_changed in ["ON", "OFF"] do
                NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time) |> convert_to_positive()
              else
                0.0
              end
            sum =
              Enum.filter(asset_status_tracks, fn ast -> ast.status_changed in ["ON", "OFF"] end)
              |> Enum.map(fn ast -> ast.hours end)
              |> Stream.filter(fn h -> !is_nil(h) end)
              |> Enum.sum()

            sum + compensation_hours * 1.0
            |> Float.ceil(2)
            |> convert_man_hours_consumed()
        end


        utilized_time =
          case length(asset_status_tracks) do
            0 ->
              IO.inspect("-----------wqe4342")
              last_entry = get_last_entry_previous(l.id, "L", naive_from_date, prefix)
              if last_entry != nil and last_entry.status_changed == "ON" do
                NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time)  |> convert_to_positive() |> convert_man_hours_consumed()
              else
                0.0
              end

            _ ->
              last_entry = List.last(asset_status_tracks)
              compensation_hours =
                if last_entry.status_changed in ["ON", "OFF"] do
                  IO.inspect(NaiveDateTime.diff(last_entry.changed_date_time, NaiveDateTime.new!(to_date, Time.new!(0,0,0))) / 3600)
                  NaiveDateTime.diff(NaiveDateTime.new!(to_date, Time.new!(0,0,0)), last_entry.changed_date_time) |> convert_to_positive()
                else
                  IO.inspect("213123")
                  0.0
                end
              sum =
                Enum.filter(asset_status_tracks, fn ast -> ast.status_changed in ["ON"] end)
                |> Enum.map(fn ast -> ast.hours end)
                |> Stream.filter(fn h -> !is_nil(h) end)
                |> Enum.sum()

              sum + compensation_hours * 1.0
              |> Float.ceil(2)
              |> convert_man_hours_consumed()
          end

      # up_time =
      #   Enum.filter(asset_status_tracks, fn ast -> ast.status in ["ON", "OFF"] end)
      #   |> Enum.map(fn ast -> ast.hours end)
      #   |> Enum.sum()

      # utilized_time =
      #   Enum.filter(asset_status_tracks, fn ast -> ast.status in ["ON"] end)
      #   |> Enum.map(fn ast -> ast.hours end)
      #   |> Enum.sum()

      ppm_work_orders =
        (from wo in WorkOrder, where: wo.asset_id == ^l.id and wo.asset_type == ^"L" and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date)
        |> Repo.all(prefix: prefix)

      completed_ppm = Enum.filter(ppm_work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()

      completion_percentage =
        if length(ppm_work_orders) != 0 do
          (completed_ppm/length(ppm_work_orders)) * 100.00
        else
          0.0
        end

      %{
        asset_name: l.name,
        asset_code: l.location_code,
        asset_type: "Location",
        asset_category_id: l.asset_category_id,
        asset_category: AssetConfig.get_asset_category!(l.asset_category_id, prefix).name,
        status: l.status,
        criticality: (if l.criticality <= 2, do: "Critical", else: "Not Critical"),
        up_time: up_time,
        utilized_time: utilized_time,
        ppm_completion_percentage: Float.ceil(completion_percentage, 2)
      }
    end)
  end

  def calendar(query_params, prefix) do
    rectified_query_params = rectify_query_params(query_params)
    asset_id = rectified_query_params["asset_id"]
    # asset_type = rectified_query_params["asset_type"]
    asset_category_id = rectified_query_params["asset_category_id"]
    asset_ids = asset_ids_based_on_filters(rectified_query_params, prefix)
    cond do
      !is_nil(asset_category_id) && !is_nil(asset_id) ->
        IO.inspect("Get directly from schedules")
        asset_category = AssetConfig.get_asset_category(asset_category_id, prefix)
        IO.inspect(asset_category)
        schedules = get_schedule_for_asset(asset_id, asset_category.asset_type, prefix)
        IO.inspect("Get Dates for each schedule")
        get_calculated_dates_for_schedules(schedules, rectified_query_params["from_date"], rectified_query_params["to_date"], asset_ids, prefix)


      !is_nil(asset_category_id) ->
        IO.inspect("Navigate from Templates to schedules")
        schedules = asset_schedule_for_asset_category(asset_category_id, prefix)
        IO.inspect("Get Dates for each schedule")
        get_calculated_dates_for_schedules(schedules, rectified_query_params["from_date"], rectified_query_params["to_date"], asset_ids, prefix)

      true ->
        IO.inspect("Not enough information is query params")
    end
  end

  def asset_ids_based_on_filters(query_params, prefix) do
    # location_query = from l in Location
    equipment_query = from e in Equipment
    dynamic_equipment_query = get_dynamic_query(query_params, equipment_query)
    case dynamic_equipment_query do
      "NO" -> []
      _  -> Repo.all(dynamic_equipment_query, prefix: prefix) |> Enum.map(fn e -> e.id end)
    end
  end

  def get_dynamic_query(query_params, query) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query ->
        from q in query, where: q.site_id == ^site_id

      {"location_id", location_id}, query ->
        from q in query, where: q.location_id == ^location_id

      _, _query ->
        "NO"
    end)
  end

  def get_calculated_dates_for_schedules(schedule_array, from_date, to_date, asset_ids, prefix) do
    Stream.map(schedule_array, fn schedule ->
        {asset_name, asset_code} = get_asset_from_type(schedule.asset_id, schedule.asset_type, prefix)
      %{
          schedule_id: schedule.schedule_id,
          # schedule_name: schedule.schedule_name,
          asset_id: schedule.asset_id,
          asset_name: asset_name,
          asset_code: asset_code,
          template_id: schedule.template_id,
          template_name: schedule.template_name,
          frequency: "#{schedule.repeat_every} #{match_repeat_unit(schedule.repeat_unit)}",
          estimated_time: schedule.estimated_time,
          dates:
            calculate_dates_for_schedule(schedule.next_occurrence, schedule.repeat_every, schedule.repeat_unit, to_date, [])
            |> Enum.filter(fn d -> Date.compare(d, convert_string_to_date(from_date)) == :gt end)
            |> Enum.filter(fn d -> Date.compare(d, schedule.applicable_start) != :lt and Date.compare(d, schedule.applicable_end) != :gt end)
        }
    end)
  |> Enum.map(fn schedule_with_date ->
        Enum.map(schedule_with_date.dates, fn date ->
          Map.put(schedule_with_date, :date, date) |> Map.drop([:dates])
        end)
      end)
  |> List.flatten()
  |> filter_for_assets(asset_ids)
  # |> Enum.sort_by(fn x ->  {x.date.year, x.date.month, x.date.day} end)
  |> Enum.group_by(&(&1.date.month))
  |> Enum.map(fn {_k, v} ->
      grouped_by_date = Enum.group_by(v, &(&1.date))
      Enum.map(grouped_by_date, fn { date, wo } ->
        %{start: date, name: "#{length(wo)}", work_order: wo}
      end)
     end)
  end
  def match_repeat_unit(unit) do
    case unit do
      "W" -> "Week"
      "M" -> "Month"
      "Y" -> "Year"
    end
  end

  def filter_for_assets(list, []), do: list

  def filter_for_assets(list, asset_ids) do
    Stream.filter(list, fn x -> x.asset_id in asset_ids end)
  end

  def get_asset_from_type(asset_id, asset_type, prefix) do
    case asset_type do
      "E" ->
        asset = AssetConfig.get_equipment(asset_id, prefix)
        {asset.name, asset.equipment_code}

      "L" ->
        asset = AssetConfig.get_location(asset_id, prefix)
        {asset.name, asset.location_code}
    end
  end

  # def calculate_dates_for_schedule(first_occurrence, repeat_every, repeat_unit, to_date, date_list \\ []) do
  #   date_list =
  #     case length(date_list) do
  #       0 -> [first_occurrence]
  #       _ -> date_list ++ [next_date(repeat_unit, repeat_every, List.last(date_list))]
  #     end
  #   # calculate_dates_for_schedule()
  # end

  def calculate_dates_for_schedule(first_occurrence_date, repeat_every, repeat_unit, to_date, []) do
    calculate_dates_for_schedule(first_occurrence_date, repeat_every, repeat_unit, to_date, [first_occurrence_date])
  end

  def calculate_dates_for_schedule(next_occurrence, repeat_every, repeat_unit, to_date, date_list) do
    date = next_date(repeat_unit, repeat_every, List.last(date_list))
    case Date.compare(date, convert_string_to_date(to_date)) do
      :lt ->
        new_date_list = date_list ++ [date]
        calculate_dates_for_schedule(next_occurrence, repeat_every, repeat_unit, to_date, new_date_list)

      _ ->
        date_list
    end
  end

  def next_date("W", repeat_every, date) do
    date |> Date.add(repeat_every *  7)
  end

  def next_date("M", repeat_every, date) do
    new_month =  date.month + repeat_every
    cond do
      new_month > 12 -> Date.new!(date.year + 1, new_month - 12, date.day)
      true -> Date.new!(date.year, new_month, date.day)
    end
  end

  def next_date("Y", _repeat_every, date) do
    Date.new!(date.year + 1, date.month, date.day)
  end

  def get_schedule_for_asset(asset_id, asset_type, prefix) do
    query =
      from wos in WorkorderSchedule, where: wos.asset_type == ^asset_type and wos.asset_id == ^asset_id and wos.is_paused == false and wos.active == true and not is_nil(wos.next_occurrence_date),
        join: wot in WorkorderTemplate, on: wot.id == wos.workorder_template_id and wot.repeat_unit not in ["H", "D"],
        select: %{
          schedule: wos,
          template: wot
        }

    execute_queryand_return_stream(query, prefix)

  end

  def asset_schedule_for_asset_category(asset_category_id, prefix) do
    asset_category_ids = AssetConfig.get_asset_category_subtree_ids(asset_category_id, prefix)
    query =
      from wot in WorkorderTemplate, where: wot.asset_category_id in ^asset_category_ids, where: wot.repeat_unit not in ["H", "D"],
       join: wos in WorkorderSchedule, on: wot.id == wos.workorder_template_id, where: wos.is_paused == false and wos.active == true and not is_nil(wos.next_occurrence_date),
       select: %{
         schedule: wos,
         template: wot
       }

    execute_queryand_return_stream(query, prefix)
  end

  def execute_queryand_return_stream(query, prefix) do
    schedule_template_data = Repo.all(query, prefix: prefix)
    # IO.inspect(schedule_template_data)

    Enum.map(schedule_template_data, fn st ->
      %{
        schedule_id: st.schedule.id,
        # schedule_name: st.schedule.name,
        asset_id: st.schedule.asset_id,
        asset_type: st.schedule.asset_type,
        template_id: st.template.id,
        template_name: st.template.name,
        first_occurrence: st.schedule.first_occurrence_date,
        next_occurrence: st.schedule.next_occurrence_date,
        repeat_unit: st.template.repeat_unit,
        repeat_every: st.template.repeat_every,
        estimated_time: st.template.estimated_time,
        applicable_start: st.template.applicable_start,
        applicable_end: st.template.applicable_end
      }
    end)
  end

  defp get_last_entry_previous(asset_id, asset_type, date_time, prefix) do
    query =
      from(ast in AssetStatusTrack,
          where: ast.asset_id == ^asset_id and
                ast.asset_type == ^asset_type and
                ast.changed_date_time <= ^date_time,
                order_by: [desc: ast.changed_date_time], limit: 1)

    Repo.one(query, prefix: prefix)
  end


  defp get_asset_from_workorder_template(work_order, prefix) do
    workorder_template = Workorder.get_workorder_template!(work_order.workorder_template_id, prefix)
    case workorder_template.asset_type do
      "L" ->
        AssetConfig.get_location(work_order.asset_id, prefix)

      "E" ->
        AssetConfig.get_equipment(work_order.asset_id, prefix)
    end
  end

  defp get_asset_type_from_workorder_template(work_order, prefix) do
    workorder_template = Workorder.get_workorder_template!(work_order.workorder_template_id, prefix)
    workorder_template.asset_type
  end

  defp convert_string_to_date(date_string) do
    [year, month, date] = String.split(date_string, "-") |> Enum.map(fn x -> String.to_integer(x) end)
    Date.new!(year, month, date)
  end

  # defp get_site_time(site_id, prefix) do
  #   site = Repo.get!(Site, site_id, prefix: prefix)
  #   date_time = DateTime.now!(site.time_zone)
  #   result = NaiveDateTime.new!(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.minute, date_time.second)
  #   NaiveDateTime.to_time(result)
  # end

  # def asset_status_reports(query_params, prefix) do
  #   {asset_type, asset_ids} = get_assets_by_asset_category_id(query_params["asset_category_id"], prefix)
  # end

  def get_assets_by_asset_category_id(asset_category_id, prefix) do
    asset_category = AssetConfig.get_asset_category!(asset_category_id, prefix)
    assets =
      case asset_category.asset_type do
        "L" ->
          Location |> where([asset_category_id: ^asset_category_id]) |> Repo.all(prefix: prefix)

        "E" ->
          Equipment |> where([asset_category_id: ^asset_category_id]) |> Repo.all(prefix: prefix)
      end
    {asset_category.asset_type, Enum.map(assets, fn a -> a.id end)}
  end

  defp rectify_query_params(query_params) do
    Enum.filter(query_params, fn {_key, value} ->
      value != "null"
  end) |> Enum.into(%{})
  end

  defp get_dates_for_query(nil, nil, site_id, prefix) do
    site = AssetConfig.get_site!(site_id, prefix)
    {
      DateTime.now!(site.time_zone) |> DateTime.to_date(),
      DateTime.now!(site.time_zone) |> DateTime.to_date()
    }
  end

  defp get_dates_for_query(from_date, nil, site_id, prefix) do
    site = AssetConfig.get_site!(site_id, prefix)
    {
      Date.from_iso8601!(from_date),
      DateTime.now!(site.time_zone) |> DateTime.to_date()
    }
  end

  defp get_dates_for_query(from_date, to_date, _site_id, _prefix) do
    {Date.from_iso8601!(from_date), Date.from_iso8601!(to_date)}
  end

  defp convert_date_to_naive_date_time(date,  "from") do
    NaiveDateTime.new!(date, Time.new!(0, 0, 0))
  end

  defp convert_date_to_naive_date_time(date,  "to") do
    NaiveDateTime.new!(date, Time.new!(23, 59, 59))
  end


  defp convert_to_pdf(report_title, filters, data, report_headers, report_for, summary \\ [], summary_headers \\ []) do
    create_report_structure(report_title, filters, data, report_headers, report_for, summary, summary_headers)
  end


  def create_summary_table(summary, summary_headers, "WR") do
    [
      :table,
      %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
      create_report_headers(summary_headers),
      create_work_request_summary_table(summary)
    ]
  end

  def create_summary_table(summary, summary_headers, "IN") do
    [
      :table,
      %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
      create_report_headers(summary_headers),
      create_inventory_table(summary)
    ]
  end

  def create_summary_table(summary, summary_headers, "AST") do
    [
      :table,
      %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
      create_report_headers(summary_headers),
      create_asset_table(summary)
    ]
  end

  def create_summary_table(summary, summary_headers, "WO") do
    [
      :table,
      %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
      create_report_headers(summary_headers),
      create_maintainance_table(summary)
    ]
  end

  def create_summary_table(summary, summary_headers, "PPL") do
    [
      :table,
      %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
      create_report_headers(summary_headers),
      create_people_table(summary)
    ]
  end

  def create_summary_table(_summary, _summary_headers, _) do
    []
  end

  def create_people_table(summary) do
    Enum.map(summary, fn s ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.department
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.shift_coverage
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.work_done
        ]
      ]
    end)
  end

  def create_maintainance_table(summary) do
    Enum.map(summary, fn s ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.asset_category
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.count_of_assets
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.total_workorder
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.completed_workorder
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.pending_workorder
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.overdue_percentage
        ]
      ]
    end)
  end

  def create_maintainance_table(summary) do
    Enum.map(summary, fn s ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.asset_category
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.total_workorder
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.completed_workorder
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.pending_workorder
        ]
      ]
    end)
  end


  def create_asset_table(summary) do
    Enum.map(summary, fn s ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.asset_category
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.count
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.count_by_status
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.ppm_completion
        ]
      ]
    end)
  end

  def create_work_request_summary_table(summary) do
    Enum.map(summary, fn s ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.ticket_category
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.count
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.resolved_count
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.open_count
        ],
      ]
    end)
  end

  def create_inventory_table(summary) do
    Enum.map(summary, fn s ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.store_location
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.count_of_receive
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.count_of_issue
        ],
        [
          :td,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          s.msl_breach_count
        ]
      ]
    end)
  end

  def create_report_structure(report_title, filters, data, _report_headers, "WOE", _summary, _summary_headers) do
    string =
      Sneeze.render(
        [
          :div,
          [
            :h1,
            %{
              style: style(%{"text-align" => "center"})
            },
            "#{report_title}"
          ],
            [
              :h2,
              if filters.licensee != nil do
                "#{filters.licensee.company_name}"
              end
            ],
            [
              :h2,
              if filters.site != nil do
                "Site: #{filters.site.name}"
              end
            ],
            [
              :div,
              %{style: style(%{"font-size" => "20px"})},
              [
                :div,
                %{style: style(%{"float" => "left", "font-size" => "20px"})},
                if filters.from_date != nil do
                  "From Date: #{filters.from_date}"
                end,
              ],
              [
                :div,
                %{style: style(%{"float" => "right", "font-size" => "20px"})},
                if filters.to_date != nil do
                  "To Date: #{filters.to_date}"
                end
              ]
            ],
          [
            :div,
            create_table_body(data, "WOE")
          ],
          [
            :h3,
            %{style: style(%{"float" => "right", "font-style" => "italic"})},
            "Powered By Inconn"
          ],
        ]
      )
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def create_report_structure(report_title, filters, data, report_headers, "WOEM", _summary, _summary_headers) do
    string =
      Sneeze.render(
        [
          :div,
          [
            :h1,
            %{
              style: style(%{"text-align" => "center"})
            },
            "#{report_title}"
          ],
            [
              :h2,
              if filters.licensee != nil do
                "#{filters.licensee.company_name}"
              end
            ],
            [
              :h2,
              if filters.site != nil do
                "Site: #{filters.site.name}"
              end
            ],
            [
              :div,
              %{style: style(%{"font-size" => "20px"})},
              [
                :div,
                %{style: style(%{"float" => "left", "font-size" => "20px"})},
                if filters.from_date != nil do
                  "From Date: #{filters.from_date}"
                end,
              ],
              [
                :div,
                %{style: style(%{"float" => "right", "font-size" => "20px"})},
                if filters.to_date != nil do
                  "To Date: #{filters.to_date}"
                end
              ]
            ],
          [
            :table,
            %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
            create_report_headers(report_headers),
            create_table_body(data, "WOEM")
          ],
          [
            :h3,
            %{style: style(%{"float" => "right", "font-style" => "italic"})},
            "Powered By Inconn"
          ]
        ]
      )
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def create_report_structure(report_title, filters, data, report_headers, report_for, summary, summary_headers) do
    string =
      Sneeze.render(
        [
          :div,
          [
            :h1,
            %{
              style: style(%{"text-align" => "center"})
            },
            "#{report_title}"
          ],
            [
              :h2,
              if filters.licensee != nil do
                "#{filters.licensee.company_name}"
              end
            ],
            [
              :h2,
              if filters.site != nil do
                "Site: #{filters.site.name}"
              end
            ],
            [
              :div,
              %{style: style(%{"font-size" => "20px"})},
              [
                :div,
                %{style: style(%{"float" => "left", "font-size" => "20px"})},
                if filters.from_date != nil do
                  "From Date: #{filters.from_date}"
                end,
              ],
              [
                :div,
                %{style: style(%{"float" => "right", "font-size" => "20px"})},
                if filters.to_date != nil do
                  "To Date: #{filters.to_date}"
                end
              ]
            ],
          [
            :table,
            %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
            create_report_headers(report_headers),
            create_table_body(data, report_for)
          ],
          [
            :h3,
            %{style: style(%{"float" => "left"})},
            "Summary"
          ],
          [
            :div,
            %{style: style(%{"margin-top" => "20px"})},
            create_summary_table(summary, summary_headers, report_for),
          ],
          [
            :h3,
            %{style: style(%{"float" => "right", "font-style" => "italic"})},
            "Powered By Inconn"
          ]
        ]
      )
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end


  defp create_report_headers(report_headers) do
    [
      :tr,
      %{
        style: style(%{"text-align" => "center"})
      },
      Enum.map(report_headers, fn h ->
        [
          :th,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          "#{h}"
        ]
      end)
    ]
  end

  defp create_task_table(tasks) do
    # IO.inspect(tasks)
    Enum.map(tasks, fn t ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          t.task.label
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          t.task.task_type
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          parse_task(t.task.task_type, t.response["answers"])
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          t.remarks
        ]
      ]
    end)
  end

  defp parse_task(_, nil), do: nil
  defp parse_task("IM", answer), do: Enum.join(answer, ",")
  defp parse_task(_, answer), do: answer


  defp create_table_body(report_body_json, "WOE") do
    Enum.map(report_body_json, fn rbj ->
      [
        :div,
        %{style: style(%{"margin-top" => "100px"})},
        [
          [
            :h1,
            "##{rbj.id} - #{rbj.asset_name} - #{rbj.workorder_template.name} - #{rbj.site.name} - #{rbj.done_by} - #{rbj.scheduled_date} #{rbj.scheduled_time} - #{rbj.range}"
          ],
          [
            :div,
            [
              :table,
              %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
              [
                :tr,
                [
                  :th,
                  %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
                  "Task Name"
                ],
                [
                  :th,
                  %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
                  "Task Type"
                ],
                [
                  :th,
                  %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
                  "Response"
                ],
                [
                  :th,
                  %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
                  "Remarks"
                ]
              ],
              create_task_table(rbj.tasks)
            ]
          ]
        ]
      ]
    end)
  end

  defp create_table_body(report_body_json, "WOEM") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.scheduled_date
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.id
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_code
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.metering_task.response["answers"]
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.metering_task.task.config["UOM"]
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          if(rbj.metering_task.response["answers"] == nil,
          do: nil,
          else:
            rbj.metering_task.response["answers"] in String.to_integer(
              rbj.metering_task.task.config["min_value"]
            )..String.to_integer(
              rbj.metering_task.task.config[
                "max_value"
              ]
            )
        )
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.done_by
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          nil
        ]
      ]
    end)
  end


  defp create_table_body(report_body_json, "PPL") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.first_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.last_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.designation
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.department
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.emp_code
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.attendance_percentage
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.work_done_time
        ]
      ]
    end)
  end

  defp create_table_body(report_body_json, "AST") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_code
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_category
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_type
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.status
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.criticality
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.up_time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.utilized_time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.ppm_completion_percentage
        ],
      ]
    end)
  end

  defp create_table_body(report_body_json, "WR") do
    IO.inspect(report_body_json)
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.date
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.ticket_type
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.ticket_category
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.ticket_subcategory
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.description
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.raised_by
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.assigned_to
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.response_tat
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.resolution_tat
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.status
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.time_taken_to_close
        ]
      ]
    end)
  end

  defp create_table_body(report_body_json, "IN") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.date
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.item_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.item_type
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.store_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.transaction_type
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.transaction_quantity
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.reorder_level
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.uom
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.aisle
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.row
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.bin
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          convert_float_to_binary(rbj.cost)
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.supplier
        ]
      ]
    end)
  end

  defp create_table_body(report_body_json, "WO") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.id
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_code
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.type
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          match_work_order_status(rbj.status)
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.assigned_to
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.converted_scheduled_date
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.converted_scheduled_time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.start_date
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.start_time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.completed_date
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.completed_time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.manhours_consumed
        ],
      ]
    end)
  end

  defp csv_for_workorder_execution(data) do
    Enum.reduce(data, [], fn d, acc ->
      head = [["WO Number: #{d.id}", "Asset: #{d.asset_name}", "Template: #{d.workorder_template.name}", "Site: #{d.site.name}"]]
      ++ [["Assigned To: #{d.done_by}", "Scheduled Date & Time: #{d.scheduled_date} #{d.scheduled_time}", "WO Status: #{match_work_order_status(d.range)}"]]
      ++ [[]]
      task_head = [["Sl.No", "Description", "Response", "Remarks"]]

      body =
        Enum.map(d.tasks, fn t ->
          case t.task.task_type do
            "IO" ->
              [
                t.id,
                t.task.label,
                Enum.find(t.task.config["options"], fn con ->
                  con["value"] == t.response["answers"]
                end)["label"],
                t.remarks
              ]

            "IM" ->
              [
                t.id,
                t.task.label,
                Enum.map(Map.get(t.response, "answers", []), fn ans ->
                  Enum.find(t.task.config["options"], fn con ->
                    con["value"] == ans
                  end)["label"]
                end)
                |> Enum.join(", "),
                t.remarks
              ]

            "MT" ->
              [
                t.id,
                t.task.label,
                "Metering: #{t.response["answers"]}",
                t.remarks
              ]

            "OB" ->
              [
                t.id,
                t.task.label,
                "Observation: #{t.response["answers"]}",
                t.remarks
              ]
          end
        end)

      res = head ++ task_head ++ body ++ [[]] ++ [[]]
      acc ++ res
    end)
  end

  defp csv_for_workorder_execution_metering(report_headers, data) do
    body =
      Enum.map(data, fn rbj ->
        [rbj.scheduled_date, rbj.id, rbj.asset_name, rbj.asset_code, rbj.metering_task.response["answers"], rbj.metering_task.task.config["UOM"],
        if(rbj.metering_task.response["answers"] == nil,
            do: nil,
            else:
              rbj.metering_task.response["answers"] in String.to_integer(
                rbj.metering_task.task.config["min_value"]
              )..String.to_integer(
                rbj.metering_task.task.config[
                  "max_value"
                ]
              )
          ),
         rbj.done_by, nil
        ]
      end)

    [report_headers] ++ body
  end

  defp csv_for_workorder_report(report_headers, data, summary, summary_headers) do
    body =
      Enum.map(data, fn d ->
        [d.id, d.asset_name, d.asset_code, d.type, match_work_order_status(d.status), d.assigned_to, d.converted_scheduled_date, d.converted_scheduled_time, d.start_date, d.start_time, d.completed_date, d.completed_time, d.manhours_consumed]
      end)

    summary =
      Enum.map(summary, fn d ->
        [d.asset_category, d.count_of_assets, d.total_workorder, d.completed_workorder, d.pending_workorder, d.overdue_percentage]
      end)

    [report_headers] ++ body ++ [[]] ++ [[]] ++ [["Summary"]] ++ [[]] ++ [summary_headers] ++ summary ++ [[]]
  end

  defp csv_for_inventory_report(report_headers, data, summary, summary_headers) do
    body =
      Enum.map(data, fn d ->
        [d.date, d.item_name, d.item_type, d.store_name, d.transaction_type, d.transaction_quantity, d.reorder_level, d.uom, d.aisle, d.row, d.bin, d.cost, d.supplier]
      end)

    summary =
      Enum.map(summary, fn d ->
        [d.store_location, d.count_of_receive, d.count_of_issue, d.msl_breach_count]
      end)

    [report_headers] ++ body ++ [[]] ++ [[]] ++ [["Summary"]] ++ [[]] ++ [summary_headers] ++ summary ++ [[]]
  end

  defp csv_for_workrequest_report(report_headers, data, summary, summary_headers) do
    body =
      Enum.map(data, fn d ->
        [d.asset_name, d.date, d.time, d.ticket_type, d.ticket_category, d.ticket_subcategory, d.description, d.raised_by, d.assigned_to, d.response_tat, d.resolution_tat, d.status, d.time_taken_to_close]
      end)

    summary =
      Enum.map(summary, fn d ->
        [d.ticket_category, d.count, d.resolved_count, d.open_count]
      end)

    [report_headers] ++ body ++ [[]] ++ [[]] ++ [["Summary"]] ++ [[]] ++ [summary_headers] ++ summary ++ [[]]

  end

  defp csv_for_asset_status_report(report_headers, data, summary, summary_headers) do
    body =
      Enum.map(data, fn d ->
        [d.asset_name, d.asset_code, d.asset_category, d.asset_type, d.status, d.criticality, d.up_time, d.utilized_time, d.ppm_completion_percentage]
      end)

    summary =
      Enum.map(summary, fn d ->
        [d.asset_category, d.count, d.count_by_status, d.ppm_completion]
      end)

    [report_headers] ++ body ++ [[]] ++ [[]] ++ [["Summary"]] ++ [[]] ++ [summary_headers] ++ summary ++ [[]]
  end

  defp csv_for_people_report(report_headers, data, summary, summary_headers) do
    body =
      Enum.map(data, fn d ->
        [d.first_name, d.last_name, d.designation, d.department, d.emp_code, d.attendance_percentage, d.work_done_time]
      end)

      summary =
        Enum.map(summary, fn d ->
          [d.department, d.shift_coverage, d.work_done]
        end)

    [report_headers] ++ body ++ [[]] ++ [[]] ++ [["Summary"]] ++ [[]] ++ [summary_headers] ++ summary ++ [[]]
  end

  # defp match_work_order_type(type) do
  #   case type do
  #     "BRK" -> "Breakdown"
  #     "PPM" -> "Preventive Maintainance"
  #     "TKT" -> "Through a Ticket"
  #     "PRV" -> "Preventive Maintainance"
  #   end
  # end

  defp match_work_order_status(status) do
    case status do
      "cr" -> "Created"
      "as" -> "Assigned"
      "ip" -> "Inprogress"
      "incp" -> "Incomplete"
      "cp" -> "Completed"
      "cn" -> "Cancelled"
      "ht" -> "Hold"
      "exec" -> "Ready for execution"
      "woap" -> "Work order approval pending"
      "wpap" -> "Work permit approval Application pending"
      "wpp" -> "Work permit pending"
      "wpa" -> "Work permit approved"
      "wpr" -> "Work permit rejected"
      "ltlap" -> "LOTO Lock application pending"
      "ltlp" -> "LOTO lock Pending"
      "prep" -> "Precheck pending"
      "ltrap" -> "LOTO Release application pending"
      "ltrp" -> "LOTO release pending"
      "ackp" -> "Acknowledgement pending"
      "execwa" -> "Ready for execution"
      _ -> status
    end
  end

  defp match_work_request_status(status) do
    case status do
      "RS" -> "Raised"
      "AP" -> "Approved"
      "AS" -> "Assigned"
      "RJ" -> "Rejected"
      "CL" -> "Cancelled"
      "CS" -> "Closed"
      "CP" -> "Completed"
      "ROP" -> "Reopened"
    end
  end

  defp match_workorder_type(type) do
    case type do
      "PRV" -> "Scheduled"
      "BRK" ->  "Breakdown"
      "TKT" -> "Ticket"
    end
  end

  defp filter_data(query_params, prefix) do
    "inc_" <> sub_domain = prefix
    licensee = Account.get_licensee_by_sub_domain(sub_domain)
    site =
            if query_params["site_id"] != nil do
              AssetConfig.get_site!(query_params["site_id"], prefix)
            else
              nil
            end

    asset =
            if query_params["asset_id"] != nil and query_params["asset_type"] != nil do
              case query_params["asset_type"] do
                "L" ->
                      AssetConfig.get_location!(query_params["asset_id"], prefix)
                "E" ->
                      AssetConfig.get_equipment!(query_params["asset_id"], prefix)
              end
            else
              nil
            end

    work_order_status =
            if query_params["status"] != nil do
              match_work_order_status(query_params["status"])
            else
              nil
            end

    user =
            if query_params["user_id"] != nil do
              Staff.get_user!(query_params["user_id"], prefix)
            else
              nil
            end

    from_date = query_params["from_date"]
    to_date = query_params["to_date"]

    %{
      licensee: licensee,
      site: site,
      asset: asset,
      work_order_status: work_order_status,
      user: user,
      from_date: from_date,
      to_date: to_date
    }
  end



  IO.inspect("---------------------------------------------------------------------------------")

  def put_sr_no(list) do
    IO.inspect(list)
    Enum.with_index(list, 1) |> Enum.map(fn {v, i} -> "<tr/><td>" <> Integer.to_string(i) <> "</td>" <> v end)
  end

  def ppm_report_query(%{"from_date" => from_date, "to_date" => to_date}, prefix) do
    query = from w in WorkOrder, where: w.type == "PRV" and w.start_date >= ^from_date or w.completed_date <= ^from_date and w.start_date >= ^to_date or w.completed_date <= ^to_date,
            join: wt in WorkorderTemplate, on: wt.id == w.workorder_template_id,
            select: %{
              wo_type: w.type,
              status: w.status,
              spares: wt.spares,
              start_date: w.start_date,
              scheduled_date: w.scheduled_date,
              scheduled_time: w.scheduled_time,
              completed_date: w.completed_date,
              asset_id: w.asset_id,
              asset_type: wt.asset_type,
              start_time: w.start_time,
              completed_time: w.completed_time,
              status: w.status,
              user_id: w.user_id,
              id: w.id }

    work_orders = Repo.all(query, prefix: prefix) |> Enum.uniq

    heading = ~s(<table border=1px solid black style="border-collapse: collapse" width="100%"><tr><th>SI. No</th><th>Asset Name</th><th>Asset Details</th><th>Status</th><th>Planned Date & Time</th><th>Actual Start Date & Time</th><th>Completed Date & Time</th><th>Assigned User</th></tr>)

    data =
      Enum.map(work_orders, fn w ->

        asset =
          case w.asset_type do
            "L" ->
              location = Inconn2Service.AssetConfig.get_location!(w.asset_id, prefix)
              %{name: location.name, type: "Location", code: location.location_code, description: location.description}

            "E" ->
              equipment = Inconn2Service.AssetConfig.get_equipment!(w.asset_id, prefix)
              location = Inconn2Service.AssetConfig.get_location!(equipment.location_id, prefix)
              %{name: equipment.name, type: "Equipment", code: equipment.equipment_code, description: "Eqiupment prsent in " <> location.name}
          end

          user = Repo.get(User, w.user_id, prefix: prefix) |> Repo.preload(:employee)
          assigned_user =
            case user.employee do
              nil -> user.username
              _ -> user.employee.first_name
            end

        "<td>#{asset.name}</td><td>#{asset.description}</td><td>#{w.status}</td><td>#{w.scheduled_date}, #{w.scheduled_time}</td><td>#{w.start_date}, #{w.start_time}</td><td>#{w.completed_date}, #{w.completed_time}</td><td>#{assigned_user}</td></tr>"

    end) |> put_sr_no() |> Enum.join

    IO.inspect(data)

    {:ok, filename} = PdfGenerator.generate(report_heading("Workorder Preventive maintainance Report") <> heading <> data <> "</table>", page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def complaints_report(prefix) do
    work_request =
      WorkRequest
      |> where(request_type: ^"CO")
      |> Repo.all(prefix: prefix)
      |> Repo.preload([requested_user: :employee, assigned_user: :employee])
      |> Repo.preload([:workrequest_subcategory])

    heading = ~s(<table border=1px solid black style="border-collapse: collapse" width="100%"><th>SI.No</th><th>Date</th><th>Time</th><th>Given By</th><th>Attended By</th><th>Response Time</th><th>Reason</th><th>ActionTaken</th><th>Close Time</th><th>Complaint type</th><th>Complaint Status</th><th>Time Taken</th>)

    data =
      Enum.map(work_request, fn w ->
        requested_user = get_name_from_user(w.requested_user)
        assigned_user = get_name_from_user(w.assigned_user)

        raised_status = get_work_request_status_track_for_type(w.id, "RS", prefix)
        created_time = raised_status.status_update_time

        response_time =
          case get_work_request_status_track_for_type(w.id, "AS", prefix) do
             nil -> "not yet attended"
             status_track ->
              Time.diff(created_time, status_track.status_update_time, :minute)
          end

        completion_time =
          case get_work_request_status_track_for_type(w.id, "CL", prefix) do
            nil -> "not yet attended"
            status_track ->
              status_track.updated_status_tome
          end

        completion_time_taken =
          case get_work_request_status_track_for_type(w.id, "CL", prefix) do
            nil -> "not yet complete"
            status_track ->
              Time.diff(created_time, status_track.status_update_time, :minute)
          end

          "<td>#{raised_status.status_update_date}</td><td>#{created_time}</td><td>#{requested_user}</td><td>#{assigned_user}</td><td>#{response_time}</td><td>#{w.reason}</td><td>#{w.action_taken}</td><td>#{completion_time}</td><td>#{w.workrequest_subcategory.name}</td><td>#{w.status}</td><td>#{completion_time_taken}</td></tr>"
      end)  |> put_sr_no() |> Enum.join

      IO.inspect(data)

      {:ok, filename} = PdfGenerator.generate(report_heading("Complaint Reports") <> heading <> data <> "</table>", page_size: "A4", command_prefix: "xvfb-run")
      {:ok, pdf_content} = File.read(filename)
      pdf_content
  end

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} ->
      "#{key}: #{value}"
    end)
    |> Enum.join(";")
  end

  def generate_qr_code_for_locations(site_id, prefix) do
    locations_qr = Inconn2Service.AssetConfig.list_locations_qr(site_id, prefix)
    "inc_" <> sub_domain = prefix

    body =
      Sneeze.render([
        :div,
        %{
          style: style(%{
            "display" => "flex",
            "flex-direction" => "column",
            "align-items" => "flex-start"
          })
        },
        render_img_qr(locations_qr, sub_domain),
      ])


    string = Sneeze.render([
      [:__@raw_html, body]])

    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def generate_ticket_qr_code_for_locations(site_id, prefix) do
    locations_qr = Inconn2Service.AssetConfig.list_locations_ticket_qr(site_id, prefix)
    "inc_" <> sub_domain = prefix

    body =
      Sneeze.render([
        [:h2, %{}, "Complaints Qr for locations"],
        [
          :div,
          %{
            style: style(%{
              "display" => "flex",
              "flex-direction" => "column",
              "align-items" => "flex-start"
            })
          },
          render_img_qr(locations_qr, sub_domain),
        ]
      ])


    string = Sneeze.render([
      [:__@raw_html, body]])

    {:ok, filename} = PdfGenerator.generate!(string, generator: :chrome, command_prefix: "xvfb-run")

    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def generate_qr_code_for_equipments(site_id, prefix) do
    equipments_qr = Inconn2Service.AssetConfig.list_equipments_qr(site_id, prefix)
    "inc_" <> sub_domain = prefix

    body =
      Sneeze.render([
        :div,
        %{
          style: style(%{
            "display" => "flex",
            "flex-direction" => "column",
            "align-items" => "flex-start"
          })
        },
        render_img_qr(equipments_qr, sub_domain),
      ])

    IO.inspect(body)
    string = Sneeze.render([
      [:__@raw_html, body]])

    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4", command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def generate_ticket_qr_code_for_equipments(site_id, prefix) do
    equipments_qr = Inconn2Service.AssetConfig.list_equipments_ticket_qr(site_id, prefix)
    "inc_" <> sub_domain = prefix

    body =
      Sneeze.render([
        [:h1, %{}, "Complaints Qr for Equipments"],
        [
          :div,
          %{
            style: style(%{
              "display" => "flex",
              "flex-direction" => "column",
              "align-items" => "flex-start"
            })
        },
        render_img_qr(equipments_qr, sub_domain),
        ]
      ])

    IO.inspect(body)
    string = Sneeze.render([
      [:__@raw_html, body]])

    {:ok, filename} = PdfGenerator.generate(string, generator: :chrome, command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end


  def render_img_qr(qr_list, sub_domain) do
    Enum.map(qr_list, fn x ->

      [
        :div,
        %{
          style: style(%{"display" => "inline-block", "padding" => "10px", "text-align" => "center"})
        },
        [
          :img,
          %{
            src: "#{get_backend_url(sub_domain)}#{x.asset_qr_url}",
            style: style(%{
              "height" => "250px",
              "width" => "250px"
            })
          },
        ],
        [:h3, %{style: style(%{"text-align" => "center", "width" => "250px"})}, "#{x.asset_name}"],
        [:h3, %{style: style(%{"text-align" => "center", "width" => "250px"})}, "#{x.asset_code}"]
      ]

    end)
  end

  def html_bootstrap_header do
  starting_tags = "<html><head>"
  bootstrap_link = ~s(<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">)
  bootstrap_script= ~s(<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>)
  starting_finish_tags = "</head>"

  starting_tags <> bootstrap_link <> bootstrap_script <> starting_finish_tags <> "<body>"
  end

  def html_bootstrap_footer, do: "</body></html>"

  def csg_workorder_report(prefix, query_params) do
    from_date = query_params["date"]
    date =
      if from_date != nil do
        Date.from_iso8601!(from_date)
      else
        Date.utc_today |> Date.add(-1)
      end

    IO.inspect(date)

    header = ~s(<p style="float:left">Site:CACIPL-Continental South Gate</p><p style="float:right">Date: #{Date.utc_today}</p>)
    heading = ~s(<table border=1px solid black style="border-collapse: collapse" width="100%"><th></th><th></th><th>7:00</th><th>9:00</th><th>11:00</th><th>13:00</th><th>15:00</th><th>17:00</th><th>19:00</th>)
    work_orders = WorkOrder |> where(scheduled_date: ^date) |> Repo.all(prefix: prefix)
    yes_count = Enum.filter(work_orders, fn w -> w.status == "cp" end) |> Enum.count()
    no_count = Enum.filter(work_orders, fn w -> w.status != "cp" end) |> Enum.count()
    work_order_groups =  work_orders |> Enum.group_by(&(&1.asset_id))
    IO.inspect(work_order_groups)

    data =
      Enum.map(work_order_groups, fn {key, work_orders} ->
        asset = Repo.get(Location, key, prefix: prefix)
        work_order_template = Repo.get(WorkorderTemplate, List.first(work_orders).workorder_template_id, prefix: prefix)
        complete_status_string =
          Enum.map(work_orders, fn w ->
            case w.status do
              "cp" -> "Y"
              _ -> "N"
            end
          end) |> Enum.join("<td>")
        "<td>" <> work_order_template.name <> " - " <> asset.name <> "</td><td>" <> complete_status_string <> "</tr>"
      end) |> put_sr_no() |> Enum.join()

      remarks_data =
        Enum.map(work_order_groups, fn {_key, work_orders} ->
          # asset = Repo.get(Location, key)
          work_order_template = Repo.get(WorkorderTemplate, List.first(work_orders).workorder_template_id, prefix: prefix)
          complete_status_string =
            Enum.map(work_orders, fn w ->
              tasks = WorkorderTask |> where([work_order_id: ^w.id]) |> Repo.all(prefix: prefix)
              Enum.map(tasks, fn t -> t.remarks end) |> Enum.filter(fn x -> x != "" end) |> Enum.join(",")
            end) |> Enum.join("<td>")
          "<td>" <> work_order_template.name <> "</td><td>" <> complete_status_string <> "</tr>"
        end) |> put_sr_no() |> Enum.join()

    IO.inspect(data)

    yes_percent =
      if yes_count + no_count != 0 do
        yes_count/(yes_count + no_count) * 100 |> Float.ceil(2)
      else
        0
      end
    no_percent =
      if yes_count + no_count != 0 do
        no_count/(yes_count + no_count) * 100 |> Float.ceil(2)
      else
        0
      end

    {:ok, filename} = PdfGenerator.generate(report_heading("Work order completion reports") <> header <> heading <> data <>  ~s(</table>) <> ~s(<div style="page-break-before: always">)<> report_heading("Total: #{yes_count + no_count}, Completed: #{yes_count}(#{yes_percent}%), Not Completed: #{no_count}(#{no_percent}%)") <> report_heading("Work order remarks generated") <> heading <> remarks_data <> "</table> <br/>" <> ~s(<p style="float:right">Powered By INCONN</p>), page_size: "A4", shell_params: ["--orientation", "landscape"], command_prefix: "xvfb-run")
    {:ok, pdf_content} = File.read(filename)
    pdf_content

  end

  def get_work_request_status_track_for_type(work_request_id, status, prefix) do
    Repo.get_by(WorkrequestStatusTrack, [work_request_id: work_request_id, status: status], prefix: prefix)
  end



  def work_order_report(prefix) do
    query = from w in WorkOrder,
            join: wt in WorkorderTemplate, on: wt.id == w.workorder_template_id,
            join: u in User, on: u.id == w.user_id,
            select: { w.type, w.status, wt.spares, w.start_time, w.completed_time, w.asset_id, wt.asset_type, u.id, w.id }

    work_orders = Repo.all(query, prefix: prefix)


    Enum.map(work_orders, fn work_order ->

      asset =
        case elem(work_order, 6) do
          "L" ->
            location = Inconn2Service.AssetConfig.get_location!(elem(work_order, 5), prefix)
            %{name: location.name, type: "Location", code: location.location_code}
          "E" ->
            equipment = Inconn2Service.AssetConfig.get_equipment!(elem(work_order, 5), prefix)
            %{name: equipment.name, type: "Equipment", code: equipment.equipment_code}
        end

        spares =
          Enum.map(elem(work_order, 2), fn s ->
            spare = Inventory.get_item!(s["id"], prefix)
            uom = Inventory.get_uom!(s["uom_id"], prefix)
            %{name: spare.name, uom: uom.symbol, quantity: s["quantity"]}
          end)

        user = Staff.get_user!(elem(work_order, 7), prefix)

        # query = from(w in WorkorderStatusTrack,
        #              where: w.work_order_id == ^elem(work_order, 8),
        #                     order_by: [desc: w.inserted_at], limit: 1)

        query = from(w in WorkorderStatusTrack,
                    where: w.work_order_id == ^elem(work_order, 8),
                    order_by: [desc: w.inserted_at], limit: 1)


        status_track = Repo.one(query, prefix: prefix)

        # status_track = Repo.get_by(query, prefix: prefix)

        assignee =
          case status_track.status do
            "as" ->
              user = Staff.get_user!(status_track.assigned_from, prefix)
              user.employee.first_name <> " " <> user.employee_last_name

            "reassigned" ->
              user = Staff.get_user!(status_track.assigned_from, prefix)
              user.employee.first_name <> " " <> user.employee_last_name

            _ ->
              ""
          end

      %{
        work_order_type: elem(work_order, 0),
        work_order_status: elem(work_order, 1),
        spares_consumed: spares,
        start_time: elem(work_order, 3),
        completed_time: elem(work_order, 4),
        asset_name: asset.name,
        asset_code: asset.code,
        asset_type: asset.type,
        employee_name: user.employee.first_name <> " " <> user.employee.last_name,
        assignee: assignee
      }
    end)

  end


  # def inventory_report(prefix) do
  #   query = from it in InventoryTransaction,
  #           join: i in Item, on: i.id == it.item_id,
  #           join: st in InventoryStock, on: st.item_id == i.id,
  #           join: u in UOM, on: u.id == it.uom_id,
  #           join: il in InventoryLocation, on: st.inventory_location_id == il.id,
  #           join: s in Supplier, on: s.id == it.supplier_id,
  #           select: { i.name, i.type, i.asset_categories_ids, st.quantity, it.quantity, i.reorder_quantity, u.symbol, il.name, i.aisle, i.bin, i.row, it.cost, s.name, it.transaction_type }

  #   inventory_items = Repo.all(query, prefix: prefix)

  #   Enum.map(inventory_items, fn inventory_item ->
  #     %{
  #       item_name: elem(inventory_item, 0),
  #       item_type: elem(inventory_item, 1),
  #       asset_categories: elem(inventory_item, 2),
  #       quantity_held: elem(inventory_item, 3),
  #       transaction_quantity: elem(inventory_item, 4),
  #       reorder_level: elem(inventory_item, 5),
  #       uom: elem(inventory_item, 6),
  #       store_name: elem(inventory_item, 7),
  #       aisle: elem(inventory_item, 8),
  #       bin: elem(inventory_item, 9),
  #       row: elem(inventory_item, 10),
  #       cost: elem(inventory_item, 11),
  #       supplier: elem(inventory_item, 12),
  #       transaction_type: elem(inventory_item, 13)
  #     }
  #   end)
  # end

  def report_heading(heading) do
    "</b><center><h1>#{heading}</h1></center>"
  end

  def get_name_from_user(user) do
    case user.employee do
      nil -> user.username
      _ -> user.employee.first_name
    end
  end
end

defmodule Inconn2Service.ReferenceDataUpdater do
  # alias Inconn2Service.Repo

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.{CheckListConfig, WorkOrderConfig, Settings, Staff, Workorder, Measurements}

  def update_table(content, schema, prefix) do
    case schema do
      "checks" ->
        Elixir.Task.start(fn -> update_checks(content, prefix) end)

      "tasks" ->
        Elixir.Task.start(fn -> update_tasks(content, prefix) end)

      "employees" ->
        Elixir.Task.start(fn -> update_employees(content, prefix) end)

      "shifts" ->
        Elixir.Task.start(fn -> update_shift(content, prefix) end)

      "workorder_tasks" ->
        update_workorder_task(content, prefix)

      _  ->
      nil
    end
  end

  def update_checks(content, prefix) do
    entries = read_and_parse_file(content)
    create_entries(CheckListConfig, entries, prefix, :update_check, :get_check)
  end

  def update_tasks(content, prefix) do
    entries = read_and_parse_file(content)
    create_entries(WorkOrderConfig, entries, prefix, :update_task, :get_task)
  end

  def update_employees(content, prefix) do
    entries = read_and_parse_file(content)
    create_entries(Staff, entries, prefix, :update_employee_for_upload, :get_employee!)
  end

  def update_shift(content, prefix) do
    entries = read_and_parse_file(content)
    create_entries(Settings, entries, prefix, :update_shift, :get_shift!)
  end

  def update_workorder_task(content, prefix) do
    entries = read_and_parse_metering_data(content) |> IO.inspect()
    Stream.map(entries, fn entry ->
      {:ok, wot} =
        Workorder.get_workorder_task_task_and_workorder!(entry["task_id"], entry["work_order_id"], prefix)
        |> Workorder.update_workorder_task(entry, prefix)
      wot
    end)
    |> Stream.map(fn wot -> wot.work_order_id end)
    |> Enum.uniq()
    |> Workorder.list_work_orders_by_ids(prefix)
    |> Stream.map(fn wo -> Map.put(wo, :scheduled_date_time, NaiveDateTime.new!(wo.scheduled_date, wo.scheduled_time)) end)
    |> Enum.sort_by(&(&1.scheduled_date_time))
    |> Enum.map(fn wo -> Measurements.record_meter_readings_from_work_order(wo, prefix) end)
  end

  def create_entries(schema, entries, prefix, update_func, get_func) do
    Enum.map(entries, fn e ->
      check = apply(schema, get_func, [e["id"], prefix])
      apply(schema, update_func, [check, e, prefix])
    end)
  end

  def read_and_parse_file(content) do
    [header | data_lines] = Path.expand(content.path) |> File.stream!() |> CSV.decode() |> Enum.map(fn {:ok, element} -> element end)
    # split_headers = String.split(header, ",")
    Stream.map(data_lines, fn line ->
      # split_lines = String.split(line, ",")
      Enum.zip(header, line) |> Enum.into(%{})
    end)
  end

  def read_and_parse_metering_data(content) do
    [header | data_lines] = Path.expand(content.path) |> File.stream!() |> CSV.decode() |> IO.inspect() |> Enum.map(fn {:ok, element} -> element end)

    Stream.map(data_lines, fn line ->
      Enum.zip(header, line) |> Enum.into(%{})
    end)
    |> Enum.map(fn m ->
      %{"task_id" => m["task_id"],
        "date_time" => convert_date_time(m["date_time"]),
        "work_order_id" => m["work_order_id"],
        "response" => %{"answers" => string_to_float(m["response"]) }}
    end)
  end

  defp convert_date_time(dt_string) do
    [date, time] = String.split(dt_string, " ")
    [day, month, year] = String.split(date, "-")
    "#{year}-#{month}-#{day} #{time}:00"
    |> NaiveDateTime.from_iso8601!()
  end
end

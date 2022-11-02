defmodule Inconn2Service.ReferenceDataUpdater do
  # alias Inconn2Service.Repo

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.{CheckListConfig, WorkOrderConfig, Settings, Staff, Workorder}

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
    Enum.map(entries, fn entry ->
      Workorder.get_workorder_task_task_and_workorder!(entry["task_id"], entry["work_order_id"], prefix)
      |> Workorder.update_workorder_task(entry, prefix)
    end)
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
    |> Enum.map(fn m -> %{"task_id" => m["task_id"], "work_order_id" => m["work_order_id"], "response" => %{"answers" => string_to_float(m["response"]) }} end)
  end
end

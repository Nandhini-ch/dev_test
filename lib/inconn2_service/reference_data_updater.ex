defmodule Inconn2Service.ReferenceDataUpdater do
  # alias Inconn2Service.Repo

  alias Inconn2Service.{CheckListConfig, WorkOrderConfig, Settings, Staff}

  def update_table(content, schema, prefix) do
    case schema do
      "checks" ->
        update_checks(content, prefix)

      "tasks" ->
        update_tasks(content, prefix)

      "employees" ->
        update_employees(content, prefix)

      "shifts" ->
        update_shift(content, prefix)
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
end

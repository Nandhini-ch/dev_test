defmodule Inconn2Service.Workorder do
  @moduledoc """
  The Workorder context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Multi
  alias Inconn2Service.Repo

  alias Inconn2Service.Common.WorkScheduler
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.{AssetConfig, WorkOrderConfig}
  alias Inconn2Service.AssetConfig.{Site, AssetCategory, Location, Equipment}
  alias Inconn2Service.WorkOrderConfig.{Task, TaskList}
  alias Inconn2Service.CheckListConfig.{Check, CheckList}
  alias Inconn2Service.Staff.{Employee, User}
  alias Inconn2Service.Settings.Shift
  alias Inconn2Service.Assignment.EmployeeRoster
  alias Inconn2Service.Inventory.Item
  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.Workorder.WorkorderCheck
  alias Inconn2Service.Staff
  alias Inconn2Service.Ticket
  alias Inconn2Service.Measurements
  alias Inconn2Service.Ticket
  alias Inconn2Service.Common
  alias Inconn2Service.Prompt

  @doc """
  Returns the list of workorder_templates.

  ## Examples

      iex> list_workorder_templates()
      [%WorkorderTemplate{}, ...]

  """
  def list_workorder_templates(prefix)  do
    Repo.all(WorkorderTemplate, prefix: prefix)
  end

  @doc """
  Gets a single workorder_template.

  Raises `Ecto.NoResultsError` if the Workorder template does not exist.

  ## Examples

      iex> get_workorder_template!(123)
      %WorkorderTemplate{}

      iex> get_workorder_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workorder_template!(id, prefix), do: Repo.get!(WorkorderTemplate, id, prefix: prefix)
  def get_workorder_template(id, prefix), do: Repo.get(WorkorderTemplate, id, prefix: prefix)

  @doc """
  Creates a workorder_template.

  ## Examples

      iex> create_workorder_template(%{field: value})
      {:ok, %WorkorderTemplate{}}

      iex> create_workorder_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workorder_template(attrs \\ %{}, prefix) do
    %WorkorderTemplate{}
    |> WorkorderTemplate.changeset(attrs)
    |> update_asset_type(prefix)
    |> validate_asset_category_id(prefix)
    |> validate_task_list_id(prefix)
    |> validate_task_ids(prefix)
    # |> validate_estimated_time(prefix)
    |> validate_workpermit_check_list_id(prefix)
    |> validate_loto_check_list_id(prefix)
    |> validate_tools(prefix)
    |> validate_spares(prefix)
    |> validate_consumables(prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp update_asset_type(cs, prefix) do
    asset_category_id = get_field(cs, :asset_category_id)
    asset_category = Repo.get(AssetCategory, asset_category_id, prefix: prefix)
    if asset_category != nil do
      asset_type = asset_category.asset_type
      case asset_type do
        "L" -> change(cs, asset_type: "L")
        "E" -> change(cs, asset_type: "E")
      end
    else
      cs
    end
  end

  defp validate_asset_category_id(cs, prefix) do
    ac_id = get_change(cs, :asset_category_id, nil)
    if ac_id != nil do
      case Repo.get(AssetCategory, ac_id, prefix: prefix) do
        nil -> add_error(cs, :asset_category_id, "Asset category ID is invalid")
        _ -> cs
      end
    else
      cs
    end
  end

  defp validate_task_list_id(cs, prefix) do
    task_list_id = get_change(cs, :task_list_id, nil)
    if task_list_id != nil do
      case Repo.get(TaskList, task_list_id, prefix: prefix) do
        nil -> add_error(cs, :task_list_id, "Task List ID is invalid")
        _ -> cs
      end
    else
      cs
    end
  end

  defp validate_task_ids(cs, prefix) do
    tasks_list_of_map = get_change(cs, :tasks, nil)
    if tasks_list_of_map != nil do
      ids = Enum.map(tasks_list_of_map, fn x -> Map.fetch!(x, "id") end)
      tasks = from(t in Task, where: t.id in ^ids )
              |> Repo.all(prefix: prefix)
      case length(ids) == length(tasks) do
        true -> cs
        false -> add_error(cs, :task_ids, "Task IDs are invalid")
      end
    else
      cs
    end
  end

  defp validate_estimated_time(cs, prefix) do
    tasks_list_of_map = get_field(cs, :tasks)
    estimated_time = get_field(cs, :estimated_time)
    task_ids = Enum.map(tasks_list_of_map, fn x -> Map.fetch!(x, "id") end)
    tasks = from(t in Task, where: t.id in ^task_ids ) |> Repo.all(prefix: prefix)
    estimated_time_list = Enum.map(tasks, fn x -> x.estimated_time end)
    estimated_time_of_all_tasks = Enum.reduce(estimated_time_list, fn x, acc -> x + acc end)
    if estimated_time >= estimated_time_of_all_tasks do
      cs
    else
      add_error(cs, :estimated_time, "Estimated time is less than total time of all the tasks")
    end
  end

  defp validate_workpermit_check_list_id(cs, prefix) do
    id = get_field(cs, :workpermit_check_list_id, nil)
    if id != nil do
      workpermit_check_list = Repo.get(CheckList, id, prefix: prefix)
      case workpermit_check_list != nil do
        true ->
                if workpermit_check_list.type == "WP" do
                  cs
                else
                  add_error(cs, :workpermit_check_list_id, "Work permit check list type is invalid")
                end
        false -> add_error(cs, :workpermit_check_list_id, "Work permit check list ID is invalid")
      end
    else
      cs
    end
  end

  defp validate_loto_check_list_id(cs, prefix) do
    lock_id = get_field(cs, :loto_lock_check_list_id, nil)
    release_id = get_field(cs, :loto_release_check_list_id, nil)
    if lock_id != nil and release_id != nil do
      lock_check_list = Repo.get(CheckList, lock_id, prefix: prefix)
      release_check_list = Repo.get(CheckList, release_id, prefix: prefix)
      case lock_check_list != nil and release_check_list != nil do
        true ->
                if lock_check_list.type == "LOTO" and release_check_list.type == "LOTO" do
                  cs
                else
                  add_error(cs, :loto_check_list_ids, "Loto check list types are invalid")
                end
        false -> add_error(cs, :loto_check_list_ids, "Loto check list IDs are invalid")
      end
    else
      cs
    end
  end

  defp validate_tools(cs, prefix) do
    tools = get_field(cs, :tools)
    if tools != [] do
      tool_maps = validate_item_map_keys(tools)
      if length(tool_maps) == length(tools) do
        tool_ids = Enum.map(tools, fn x -> x["id"] end)
        validate_item_ids(cs, tool_ids, prefix)
      else
        add_error(cs, :tools, "is invalid")
      end
    else
      cs
    end
  end

  defp validate_spares(cs, prefix) do
    spares = get_field(cs, :spares)
    if spares != [] do
      spare_maps = validate_item_map_keys(spares)
      if length(spare_maps) == length(spares) do
        spare_ids = Enum.map(spares, fn x -> x["id"] end)
        validate_item_ids(cs, spare_ids, prefix)
      else
        add_error(cs, :spares, "is invalid")
      end
    else
      cs
    end
  end

  defp validate_consumables(cs, prefix) do
    consumables = get_field(cs, :consumables)
    if consumables != [] do
      consumable_maps = validate_item_map_keys(consumables)
      if length(consumable_maps) == length(consumables) do
        consumable_ids = Enum.map(consumables, fn x -> x["id"] end)
        validate_item_ids(cs, consumable_ids, prefix)
      else
        add_error(cs, :consumables, "is invalid")
      end
    else
      cs
    end
  end

  defp validate_item_map_keys(items) do
    Enum.filter(items, fn item ->
                    Map.keys(item) == ["id", "quantity", "uom_id"]
                  end)
  end

  defp validate_item_ids(cs, item_ids, prefix) do
    if item_ids != [] do
      items = from(i in Item, where: i.id in ^item_ids)
              |> Repo.all(prefix: prefix)
      case length(item_ids) == length(items) do
        true -> cs
        false -> add_error(cs, :items, "Item IDs are invalid")
      end
    else
      cs
    end
  end
  @doc """
  Updates a workorder_template.

  ## Examples

      iex> update_workorder_template(workorder_template, %{field: new_value})
      {:ok, %WorkorderTemplate{}}

      iex> update_workorder_template(workorder_template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workorder_template(%WorkorderTemplate{} = workorder_template, attrs, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(attrs)
    |> update_asset_type(prefix)
    |> validate_asset_category_id(prefix)
    |> validate_task_list_id(prefix)
    |> validate_task_ids(prefix)
    # |> validate_estimated_time(prefix)
    |> validate_workpermit_check_list_id(prefix)
    |> validate_loto_check_list_id(prefix)
    |> validate_tools(prefix)
    |> validate_spares(prefix)
    |> validate_consumables(prefix)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a workorder_template.

  ## Examples

      iex> delete_workorder_template(workorder_template)
      {:ok, %WorkorderTemplate{}}

      iex> delete_workorder_template(workorder_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workorder_template(%WorkorderTemplate{} = workorder_template, prefix) do
    Repo.delete(workorder_template, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workorder_template changes.

  ## Examples

      iex> change_workorder_template(workorder_template)
      %Ecto.Changeset{data: %WorkorderTemplate{}}

  """
  def change_workorder_template(%WorkorderTemplate{} = workorder_template, attrs \\ %{}) do
    WorkorderTemplate.changeset(workorder_template, attrs)
  end

  alias Inconn2Service.Workorder.WorkorderSchedule
  alias Inconn2Service.Common
  alias Inconn2Service.Settings
  @doc """
  Returns the list of workorder_schedules.

  ## Examples

      iex> list_workorder_schedules()
      [%WorkorderSchedule{}, ...]

  """
  def list_workorder_schedules(prefix) do
    WorkorderSchedule
    |> where([active: true])
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:workorder_template)
  end

  def list_workorder_schedules(query_params, prefix) do
    WorkorderSchedule
    |> Repo.add_active_filter(query_params)
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:workorder_template)
  end

  @doc """
  Gets a single workorder_schedule.

  Raises `Ecto.NoResultsError` if the Workorder schedule does not exist.

  ## Examples

      iex> get_workorder_schedule!(123)
      %WorkorderSchedule{}

      iex> get_workorder_schedule!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workorder_schedule!(id, prefix), do: Repo.get!(WorkorderSchedule, id, prefix: prefix) |> Repo.preload(:workorder_template)

  @doc """
  Creates a workorder_schedule.

  ## Examples

      iex> create_workorder_schedule(%{field: value})
      {:ok, %WorkorderSchedule{}}

      iex> create_workorder_schedule(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workorder_schedule(attrs \\ %{}, prefix) do
    result = %WorkorderSchedule{}
              |> WorkorderSchedule.changeset(attrs)
              |> validate_asset_id(prefix)
              |> validate_for_future_date(prefix)
              |> validate_first_occurence_time(prefix)
              |> calculate_next_occurrence(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, workorder_schedule} ->
          zone = get_time_zone(workorder_schedule, prefix)
          Common.create_work_scheduler(%{"prefix" => prefix, "workorder_schedule_id" => workorder_schedule.id, "zone" => zone})
          {:ok, Repo.get!(WorkorderSchedule, workorder_schedule.id, prefix: prefix) |> Repo.preload(:workorder_template)}
      _ ->
        result
    end
  end

  defp get_time_zone(workorder_schedule, prefix) do
    asset_id = workorder_schedule.asset_id
    asset_type = workorder_schedule.asset_type
    case asset_type do
      "L" -> site_id = Repo.get(Location, asset_id, prefix: prefix).site_id
             Repo.get(Site, site_id, prefix: prefix).time_zone
      "E" -> site_id = Repo.get(Equipment, asset_id, prefix: prefix).site_id
             Repo.get(Site, site_id, prefix: prefix).time_zone
    end
  end

  defp validate_asset_id(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    asset_id = get_field(cs, :asset_id)
    workorder_template = Repo.get(WorkorderTemplate, workorder_template_id, prefix: prefix)
    if workorder_template != nil and asset_id != nil do
      asset_category = Repo.get(AssetCategory, workorder_template.asset_category_id, prefix: prefix)
      asset_type = asset_category.asset_type
      case asset_type do
        "L" ->
          case Repo.get(Location, asset_id, prefix: prefix) != nil do
            true -> change(cs, asset_type: "L")
            false -> add_error(cs, :asset_id, "Asset ID is invalid")
          end
        "E" ->
          case Repo.get(Equipment, asset_id, prefix: prefix) != nil do
            true -> change(cs, asset_type: "E")
            false -> add_error(cs, :asset_id, "Asset ID is invalid")
          end
        end
      else
        cs
      end
  end

  defp validate_first_occurence_time(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id, nil)
    first_time = get_change(cs, :first_occurrence_time, nil)
    if workorder_template_id != nil and first_time != nil do
      workorder_template = Repo.get(WorkorderTemplate, workorder_template_id, prefix: prefix)
      time_start = workorder_template.time_start
      time_end = workorder_template.time_end
      if time_start != nil and time_end != nil do
        if first_time < time_start or first_time > time_end do
          add_error(cs, :first_occurrence_time, "should be within the time limit of workorder template")
        else
          cs
        end
      else
        cs
      end
    else
      cs
    end
  end

  defp validate_for_future_date(cs, prefix) do
    if Map.has_key?(cs.changes, :first_occurrance_date) or Map.has_key?(cs.changes, :first_occurrance_time) do
      first_occurrance_date = get_field(cs, :first_occurrance_date)
      first_occurrance_time = get_field(cs, :first_occurrance_time)
      asset_id = get_field(cs, :asset_id, nil)
      asset_type = get_field(cs, :asset_type, nil)
      if asset_id != nil and asset_type != nil and first_occurrance_date != nil and first_occurrance_time != nil do
        asset = AssetConfig.get_asset_by_type(asset_id, asset_type, prefix)
        if asset != nil do
          {date, time} = get_date_time_in_required_time_zone(asset.site_id, prefix)
          dt = NaiveDateTime.new!(date, time)
          f_dt = NaiveDateTime.new!(first_occurrance_date, first_occurrance_time)
          case Date.compare(f_dt, dt) do
            :gt ->
              cs

            _ ->
              add_error(cs, :first_occurance_date, "Date and time should be in the future")
              |> add_error(:first_occurance_time, "Date and time should be in the future")
          end
        else
          cs
        end
      else
        cs
      end
    else
      cs
    end
  end


  defp get_date_time_in_required_time_zone(site_id, prefix) do
    site = Repo.get!(Site, site_id, prefix: prefix)
    date_time = DateTime.now!(site.time_zone)
    {Date.new!(date_time.year, date_time.month, date_time.day), Time.new!(date_time.hour, date_time.minute, date_time.second)}
  end

  defp calculate_next_occurrence(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id, nil)
    first_date = get_field(cs, :first_occurrence_date, nil)
    first_time = get_field(cs, :first_occurrence_time, nil)
    if get_change(cs, :first_occurrence_date, nil) != nil or get_change(cs, :first_occurrence_time, nil) != nil do
        workorder_template = Repo.get(WorkorderTemplate, workorder_template_id, prefix: prefix)
        if workorder_template != nil do
          applicable_start = workorder_template.applicable_start
          case Date.compare(applicable_start,first_date) do
            :gt ->
              add_error(cs, :first_occurrence_date, "should be greater than or equal to applicable start date")
            _ ->
              change(cs, %{next_occurrence_date: first_date, next_occurrence_time: first_time})
          end
        else
          cs
        end
    else
      cs
    end
  end

  @doc """
  Updates a workorder_schedule.

  ## Examples

      iex> update_workorder_schedule(workorder_schedule, %{field: new_value})
      {:ok, %WorkorderSchedule{}}

      iex> update_workorder_schedule(workorder_schedule, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workorder_schedule(%WorkorderSchedule{} = workorder_schedule, attrs, prefix) do
    result = workorder_schedule
              |> WorkorderSchedule.changeset(attrs)
              |> validate_asset_id(prefix)
              |> validate_for_future_date(prefix)
              |> validate_first_occurence_time(prefix)
              |> calculate_next_occurrence(prefix)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, workorder_schedule} ->
          zone = get_time_zone(workorder_schedule, prefix)
          work_scheduler = Repo.get_by(WorkScheduler, [workorder_schedule_id: workorder_schedule.id, prefix: prefix])
          case work_scheduler do
            nil ->
              {:ok, Repo.get!(WorkorderSchedule, workorder_schedule.id, prefix: prefix) |> Repo.preload(:workorder_template)}

            _ ->
              if attrs["first_occurrence_date"] != nil or attrs["first_occurrence_time"] != nil do
                Common.delete_work_scheduler(workorder_schedule.id, prefix)
                Common.create_work_scheduler(%{"prefix" => prefix, "workorder_schedule_id" => workorder_schedule.id, "zone" => zone})
                {:ok, Repo.get!(WorkorderSchedule, workorder_schedule.id, prefix: prefix) |> Repo.preload(:workorder_template)}
              else
                {:ok, Repo.get!(WorkorderSchedule, workorder_schedule.id, prefix: prefix) |> Repo.preload(:workorder_template)}
              end
          end
      _ ->
        result
    end
  end


  defp update_next_occurrence(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    site_id = get_site_id(cs, prefix)
    workorder_template = get_workorder_template!(workorder_template_id, prefix)
    applicable_start = workorder_template.applicable_start
    applicable_end = workorder_template.applicable_end
    time_start = workorder_template.time_start
    time_end = workorder_template.time_end
    repeat_every = workorder_template.repeat_every
    repeat_unit = workorder_template.repeat_unit
    first_occurrence_date = get_field(cs, :first_occurrence_date)
    first_occurrence_time = get_field(cs, :first_occurrence_time)
    next_occurrence_date = get_field(cs, :next_occurrence_date)
    next_occurrence_time = get_field(cs, :next_occurrence_time)
    if next_occurrence_date != nil and next_occurrence_time != nil do
      case repeat_unit do
        "H" ->
          time = Time.add(next_occurrence_time, repeat_every*3600) |> Time.truncate(:second)
          date = next_occurrence_date
          if time >= time_start and time <= time_end do
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_for_bank_holidays(site_id, applicable_start, applicable_end, prefix)
            |> check_for_holidays()
            |> check_before_applicable_date(applicable_end)
          else
            time = first_occurrence_time
            date = Date.add(next_occurrence_date, 1)
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_for_bank_holidays(site_id, applicable_start, applicable_end, prefix)
            |> check_for_holidays()
            |> check_before_applicable_date(applicable_end)
          end
        "D" ->
          time = first_occurrence_time
          date = Date.add(next_occurrence_date, repeat_every)
          change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          |> check_for_bank_holidays(site_id, applicable_start, applicable_end, prefix)
          |> check_for_holidays()
          |> check_before_applicable_date(applicable_end)
        "W" ->
          time = first_occurrence_time
          date = Date.add(next_occurrence_date, repeat_every*7)
          change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          |> check_for_bank_holidays(site_id, applicable_start, applicable_end, prefix)
          |> check_before_applicable_date(applicable_end)
        "M" ->
          time = first_occurrence_time
          month = next_occurrence_date.month + repeat_every
          if month > 12 do
            date = Date.new!(next_occurrence_date.year + 1, month - 12, first_occurrence_date.day)
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_for_bank_holidays(site_id, applicable_start, applicable_end, prefix)
            |> check_for_holidays()
            |> check_before_applicable_date(applicable_end)
          else
            date = date_valid_in_every_month(next_occurrence_date.year, month, first_occurrence_date.day)
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_for_bank_holidays(site_id, applicable_start, applicable_end, prefix)
            |> check_for_holidays()
            |> check_before_applicable_date(applicable_end)
          end
        "Y" ->
            time = first_occurrence_time
            date = Date.new!(next_occurrence_date.year + repeat_every, first_occurrence_date.month, first_occurrence_date.day)
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_for_bank_holidays(site_id, applicable_start, applicable_end, prefix)
            |> check_for_holidays()
            |> check_before_applicable_date(applicable_end)
      end
    else
      cs
    end
  end

  defp date_valid_in_every_month(year, month, day) do
    date = Date.new(year, month, day)
    case date do
      {:ok, date} -> date
      {:error, _} -> date_valid_in_every_month(year, month, day-1)
    end
  end

  defp check_before_applicable_date(cs, applicable_end) do
    next_occurrence_date = get_field(cs, :next_occurrence_date)
    case Date.compare(next_occurrence_date, applicable_end) == :gt do
      false -> cs
      true -> change(cs, %{next_occurrence_date: nil, next_occurrence_time: nil})
    end
  end

  def check_for_holidays(cs) do
    next_occurrence_date = get_field(cs, :next_occurrence_date)
    holidays = get_field(cs, :holidays)
    case Date.day_of_week(next_occurrence_date) in holidays do
      true -> next_occurrence_date = Date.add(next_occurrence_date, 1)
              cs = change(cs, next_occurrence_date: next_occurrence_date)
              check_for_holidays(cs)
      false -> cs
    end
  end

  def check_for_bank_holidays(cs, site_id, applicable_start, applicable_end, prefix) do
    next_occurrence_date = get_field(cs, :next_occurrence_date)
    year_begin = applicable_start
    year_end = applicable_end
    holidays = Settings.list_bankholidays(site_id, year_begin, year_end, prefix)
    holiday = check_which_bank_holidays(next_occurrence_date, holidays)
    case holiday do
      nil ->
              cs
      _ ->
              next_occurrence_date = Date.add(holiday.end_date, 1)
              cs = change(cs, next_occurrence_date: next_occurrence_date)
              check_for_bank_holidays(cs, site_id, applicable_start, applicable_end, prefix)
    end
  end

  defp check_which_bank_holidays(next_occurrence_date, holidays) do
    holidays_boolean = Enum.map(holidays, fn holiday ->
                                                if (holiday.start_date) <= next_occurrence_date and next_occurrence_date <= (holiday.end_date) do
                                                  true
                                                else
                                                  false
                                                end
                                            end)
    holiday_index = Enum.find_index(holidays_boolean, fn x -> x == true end)
    if holiday_index != nil do
      Enum.at(holidays, holiday_index)
    else
      nil
    end
  end

  defp get_site_id(cs, prefix) do
    asset_id = get_field(cs, :asset_id)
    case get_field(cs, :asset_type) do
      "L" ->  location = Repo.get!(Location, asset_id, prefix: prefix)
              location.site_id
      "E" ->  equipment = Repo.get!(Equipment, asset_id, prefix: prefix)
              equipment.site_id
    end
  end

  @doc """
  Deletes a workorder_schedule.

  ## Examples

      iex> delete_workorder_schedule(workorder_schedule)
      {:ok, %WorkorderSchedule{}}

      iex> delete_workorder_schedule(workorder_schedule)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workorder_schedule(%WorkorderSchedule{} = workorder_schedule, prefix) do
    Repo.delete(workorder_schedule, prefix: prefix)
  end

  def deactivate_workorder_schedule(%WorkorderSchedule{} = workorder_schedule, prefix) do
    result =
      workorder_schedule
      |> WorkorderSchedule.changeset(%{"active" => false})
      |> Repo.update(prefix: prefix)

    case result do
      {:ok, updated_workorder_schedule} ->
        query = from wosr in WorkScheduler, where: wosr.workorder_schedule_id == ^workorder_schedule.id and wosr.prefix == ^prefix
        Repo.delete_all(query)
        {:ok, updated_workorder_schedule}

      _ ->
        result
    end


  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workorder_schedule changes.

  ## Examples

      iex> change_workorder_schedule(workorder_schedule)
      %Ecto.Changeset{data: %WorkorderSchedule{}}

  """
  def change_workorder_schedule(%WorkorderSchedule{} = workorder_schedule, attrs \\ %{}) do
    WorkorderSchedule.changeset(workorder_schedule, attrs)
  end


  alias Inconn2Service.Workorder.WorkOrder
  @doc """
  Returns the list of work_orders.

  ## Examples

      iex> list_work_orders()
      [%WorkOrder{}, ...]

  """
  def list_work_orders(prefix) do
    Repo.all(WorkOrder, prefix: prefix)
    |> Enum.map(fn work_order -> get_work_order_with_asset(work_order, prefix) end)
  end

  def list_active_work_orders(prefix) do
    query = from wo in WorkOrder, where: wo.status != "cp"
    Repo.all(query, prefix: prefix) |> Enum.map(fn work_order -> get_work_order_with_asset(work_order, prefix) end)
  end

  def list_work_orders_for_user_by_qr(qr_string, user, prefix) do
    [asset_type, uuid] = String.split(qr_string, ":")
    case asset_type do
      "L" ->
        location = Inconn2Service.AssetConfig.get_location_by_qr_code(uuid, prefix)
        WorkOrder
        |> where([asset_id: ^location.id, asset_type: ^"L" ,user_id: ^user.id])
        |> where([w], w.status != "cp")
        |> Repo.all(prefix: prefix)
        |> Enum.map(fn work_order -> add_stuff_to_workorder(work_order, prefix) end)

      "E" ->
        equipment = Inconn2Service.AssetConfig.get_equipment_by_qr_code(uuid, prefix)
        WorkOrder
        |> where([asset_id: ^equipment.id, asset_type: "E", user_id: ^user.id])
        |> where([w], w.status != "cp")
        |> Repo.all(prefix: prefix)
        |> Enum.map(fn work_order -> add_stuff_to_workorder(work_order, prefix) end)
    end
  end

  def list_work_orders_of_user(prefix, user \\ %{id: nil, employee_id: nil}) do
    employee =
      case user.employee_id do
        nil ->
          nil

        id ->
          Staff.get_employee!(id, prefix)
      end

    query_for_assigned = from wo in WorkOrder, where: wo.user_id == ^user.id and wo.status != "cp"
    assigned_work_orders = Repo.all(query_for_assigned, prefix: prefix)

    asset_category_workorders =

      case employee do
        nil ->
          []

        employee ->
          query =
            from wo in WorkOrder, where: wo.status != "cp",
              left_join: wt in WorkorderTemplate, on: wt.id == wo.workorder_template_id and wt.asset_category_id in ^employee.skills
          Repo.all(query, prefix: prefix)
      end

    Enum.uniq(assigned_work_orders ++ asset_category_workorders)
    |> Enum.filter(fn wo -> wo.is_deactivated != true end)
    |> Enum.map(fn work_order -> get_work_order_with_asset(work_order, prefix) end)

    end

  @doc """
  Gets a single work_order.

  Raises `Ecto.NoResultsError` if the Work order does not exist.

  ## Examples

      iex> get_work_order!(123)
      %WorkOrder{}

      iex> get_work_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work_order!(id, prefix) do
    work_order = Repo.get!(WorkOrder, id, prefix: prefix)
    case is_struct(work_order) do
      true ->
        get_work_order_with_asset(work_order, prefix)
      false ->
        work_order
    end
  end

  def get_work_orders_by_workorder_schedule_id(workorder_schedule_id, prefix) do
    from(wo in WorkOrder, where: wo.workorder_schedule_id == ^workorder_schedule_id)
    |> Repo.all(prefix: prefix)
  end

  def get_work_order_premits_to_be_approved(user, prefix) do
    work_orders = WorkOrder |> where(status: "wpp") |> Repo.all(prefix: prefix)
    Enum.map(work_orders, fn wo ->
      if List.first(wo.workpermit_required_from -- wo.workpermit_obtained) == user.id do
        wo
      else
        "not_required"
      end
    end) |> Enum.filter(fn x -> x != "not_required" end)
    |> Enum.filter(fn wo -> wo.is_deactivated != true end)
  end

  def get_work_order_loto_to_be_checked(user, prefix) do
    WorkOrder
    |> where([loto_approval_from_user_id: ^user.id, status: ^"ltp"])
    |> Repo.all(prefix: prefix)
  end
  @doc """
  Creates a work_order.

  ## Examples

      iex> create_work_order(%{field: value})
      {:ok, %WorkOrder{}}

      iex> create_work_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work_order(attrs \\ %{}, prefix, user \\ %{id: nil}) do
    result = %WorkOrder{}
              |> WorkOrder.changeset(attrs)
              |> status_created(prefix)
              |> status_assigned(prefix)
              |> validate_site_id(prefix)
              |> validate_asset_id_workorder(prefix)
              |> validate_user_id(prefix)
              |> validate_workorder_template_id(prefix)
              |> validate_workorder_schedule_id(prefix)
              |> prefill_asset_type(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, work_order} ->
          create_status_track(work_order, user, prefix)
      _ ->
        result
    end
  end

  defp prefill_asset_type(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id, nil)
    if workorder_template_id != nil do
      workorder_template = get_workorder_template!(workorder_template_id, prefix)
      change(cs, %{asset_type: workorder_template.asset_type})
    else
      cs
    end
  end

  defp validate_site_id(cs, prefix) do
    site_id = get_field(cs, :site_id, nil)
    if site_id != nil do
      site = Repo.get(Site, site_id, prefix: prefix)
      case site != nil do
        true -> cs
        false -> add_error(cs, :site_id, "site_id is invalid")
      end
    else
      cs
    end
  end

  defp validate_asset_id_workorder(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    asset_id = get_field(cs, :asset_id)
    workorder_template = Repo.get(WorkorderTemplate, workorder_template_id, prefix: prefix)
    if workorder_template != nil and asset_id != nil do
      asset_category = Repo.get(AssetCategory, workorder_template.asset_category_id, prefix: prefix)
      asset_type = asset_category.asset_type
      case asset_type do
        "L" ->
          location = Repo.get(Location, asset_id, prefix: prefix)
          case location != nil do
            true -> change(cs, site_id: location.site_id)
            false -> add_error(cs, :asset_id, "Asset ID is invalid")
          end
        "E" ->
          equipment = Repo.get(Equipment, asset_id, prefix: prefix)
          case equipment != nil do
            true -> change(cs,site_id: equipment.site_id)
            false -> add_error(cs, :asset_id, "Asset ID is invalid")
          end
        end
      else
        cs
      end
  end

  defp validate_user_id(cs, prefix) do
    user_id = get_field(cs, :user_id, nil)
    if user_id != nil do
      user = Repo.get(User, user_id, prefix: prefix)
      case user != nil do
        true -> cs
        false -> add_error(cs, :user_id, "user_id is invalid")
      end
    else
      cs
    end
  end

  defp validate_workorder_template_id(cs, prefix) do
    template_id = get_field(cs, :workorder_template_id, nil)
    if template_id != nil do
      template = Repo.get(WorkorderTemplate, template_id, prefix: prefix)
      case template != nil do
        true -> cs
        false -> add_error(cs, :workorder_template_id, "workorder_template_id is invalid")
      end
    else
      cs
    end
  end

  defp validate_workorder_schedule_id(cs, prefix) do
    schedule_id = get_field(cs, :workorder_schedule_id, nil)
    if schedule_id != nil do
      schedule = Repo.get(WorkorderSchedule, schedule_id, prefix: prefix)
      case schedule != nil do
        true -> cs
        false -> add_error(cs, :workorder_schedule_id, "workorder_schedule_id is invalid")
      end
    else
      cs
    end
  end


  def get_work_order_with_asset(work_order, prefix) do
    work_order = add_overdue_flag(work_order, prefix)
    workorder_template_id = work_order.workorder_template_id
    asset_id = work_order.asset_id
    workorder_template = get_workorder_template(workorder_template_id, prefix)
    if workorder_template != nil and asset_id != nil do
      asset_type = workorder_template.asset_type
      case asset_type do
        "L" ->
          location = AssetConfig.get_location(asset_id, prefix)
          Map.put_new(work_order, :asset_type, "L") |> Map.put_new(:asset_name, location.name)
        "E" ->
          equipment = AssetConfig.get_equipment(asset_id, prefix)
          Map.put_new(work_order, :asset_type, "E") |> Map.put_new(:asset_name, equipment.name)
      end
    else
      Map.put_new(work_order, :asset_type, nil) |> Map.put_new(:asset_name, nil)
    end
  end

  defp add_overdue_flag(work_order, prefix) do
    site = AssetConfig.get_site!(work_order.site_id, prefix)
    site_dt = DateTime.now!(site.time_zone)
    site_dt = DateTime.to_naive(site_dt)
    scheduled_dt = NaiveDateTime.new!(work_order.scheduled_date, work_order.scheduled_time)
    case NaiveDateTime.compare(scheduled_dt, site_dt) do
      :lt -> Map.put_new(work_order, :overdue, true)
      _ -> Map.put_new(work_order, :overdue, false)
    end
  end

  def update_asset_status(work_order, attrs, prefix) do
    case work_order.asset_type do
      "L" ->
          location = AssetConfig.get_location(work_order.asset_id, prefix)
          AssetConfig.update_location(location, attrs, prefix)
      "E" ->
          equipment = AssetConfig.get_equipment(work_order.asset_id, prefix)
          AssetConfig.update_equipment(equipment, attrs, prefix)
    end
  end
  @doc """
  Updates a work_order.

  ## Examples

      iex> update_work_order(work_order, %{field: new_value})
      {:ok, %WorkOrder{}}

      iex> update_work_order(work_order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_order(%WorkOrder{} = work_order, attrs, prefix, user) do
    result = work_order
            |> WorkOrder.changeset(attrs)
            |> validate_site_id(prefix)
            |> validate_asset_id_workorder(prefix)
            |> self_assign(work_order, user)
            |> validate_user_id(prefix)
            |> status_assigned(work_order, user, prefix)
            |> status_reassigned(work_order, user, prefix)
            |> status_rescheduled(work_order, user, prefix)
            |> update_status(work_order, user, prefix)
            |> prevent_updating_deactivated_work_order(work_order)
            |> validate_workorder_template_id(prefix)
            |> validate_workorder_schedule_id(prefix)
            |> Repo.update(prefix: prefix)

    case result do
      {:ok, updated_work_order} ->
          # auto_update_workorder_task(work_order, prefix)
          record_meter_readings(work_order, updated_work_order, prefix)
          change_ticket_status(work_order, updated_work_order, user, prefix)
          result
      _ ->
        result
    end
  end


  def push_alert_notification_for_work_order(existing_work_order, updated_work_order, prefix) do
    workorder_template = get_workorder_template!(updated_work_order.workorder_template_id, prefix)
    {asset, _workorder_schedule} = get_asset_from_work_order(updated_work_order, prefix)
    cond do
      is_nil(existing_work_order.user_id) && !is_nil(updated_work_order.user_id) ->
        description = ~s(New Work Order Assigned, #{asset.name} with template #{workorder_template.name})
        create_work_order_alert_notification("WOAS", existing_work_order, updated_work_order, description, "assigned_work_order", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "wpp" ->
        description = ~s(Work Permit Required for template #{workorder_template.name} on #{asset.name})
        create_work_order_alert_notification("WPAR", existing_work_order, updated_work_order, description, "workpermit_approval_required",prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "wpa" ->
        description = ~s(Work Permit Approved for template #{workorder_template.name} on #{asset.name})
        create_work_order_alert_notification("WPAP", existing_work_order, updated_work_order, description, "workpermit_approved", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "ltp" ->
        description = ~s(Loto Required for template #{workorder_template.name} on #{asset.name})
        create_work_order_alert_notification("LTAR", existing_work_order, updated_work_order, description, "loto_required", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "lta" ->
        description = ~s(Loto Approved for template #{workorder_template.name} on #{asset.name})
        create_work_order_alert_notification("LTAP", existing_work_order, updated_work_order, description, "loto_approved", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "woap" ->
        description = ~s(Workorder Approval Required for #{asset.name} with template #{workorder_template.name})
        create_work_order_alert_notification("WOAR", existing_work_order, updated_work_order, description, "work_order_approval_required", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "woaa" ->
        description = ~s(Workorder for #{asset.name} with template #{workorder_template.name} approved)
        create_work_order_alert_notification("WOAP", existing_work_order, updated_work_order, description, "work_order_approved", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "ackp" ->
        description = ~s(Workorder for #{asset.name} to be acknowledged)
        create_work_order_alert_notification("WACR", existing_work_order, updated_work_order, description, "work_order_acknowledge_pending", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "ackr" ->
        description = ~s(Workorder for #{asset.name} has been acknowledged)
        create_work_order_alert_notification("WACK", existing_work_order, updated_work_order, description, "work_order_acknowledged", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "hl" ->
        description = ~s(Workorder for #{asset.name} has been put on hold)
        create_work_order_alert_notification("WOHL", existing_work_order, updated_work_order, description, "work_order_hold", prefix)

      existing_work_order.status != updated_work_order.status  && updated_work_order.status == "cn" ->
        description = ~s(Workorder for #{asset.name} has been cancelled)
        create_work_order_alert_notification("WOCL", existing_work_order, updated_work_order, description, "work_order_cancelled", prefix)

      existing_work_order.scheduled_date != updated_work_order.scheduled_date ->
        description = ~s(Workorder for #{asset.name} has been rescheduled)
        create_work_order_alert_notification("WORE", existing_work_order, updated_work_order, description, "work_order_rescheduled", prefix)

      existing_work_order.user_id != updated_work_order.user_id ->
        description = ~s(Workorder for #{asset.name} has been re-assigned)
        create_work_order_alert_notification("WORE", existing_work_order, updated_work_order, description, "work_order_reassigned", prefix)

      true ->
        {:ok, updated_work_order}
    end
  end


  def create_work_order_alert_notification(alert_code, _existing_work_order, updated_work_order, description, action_for, prefix) do
    alert = Common.get_alert_by_code(alert_code)
    alert_config = Prompt.get_alert_notification_config_by_alert_id(alert.id, prefix)
    {asset, workorder_schedule}  = get_asset_from_work_order(updated_work_order, prefix)
    attrs = %{
      "alert_notification_id" => alert.id,
      "asset_id" => asset.id,
      "asset_type" => workorder_schedule.asset_type,
      "type" => alert.type,
      "description" => description
    }

    config_user_ids =
      case alert_config do
        nil -> []
        _ -> alert_config.addressed_to_user_ids
      end

    case action_for do

      "assigned_work_order" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "workpermit_approval_required" ->
        Enum.map(alert_config.addressed_to_user_ids ++ updated_work_order.workpermit_required_from, fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "workpermit_approved" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "loto_required" ->
        Enum.map(config_user_ids ++ [updated_work_order.loto_approval_from_user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "loto_approved" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_approval_required" ->
        Enum.map(config_user_ids ++ [updated_work_order.work_order_approval_user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_approved" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_acknowledge_pending" ->
        Enum.map(config_user_ids ++ [updated_work_order.workorder_acknowledgement_user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_acknowledged" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_hold" ->
        Enum.map(config_user_ids ++ config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_cancelled" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_rescheduled" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)

      "work_order_reassigned" ->
        Enum.map(config_user_ids ++ [updated_work_order.user_id], fn id ->
          Prompt.create_user_alert(Map.put_new(attrs, "user_id", id), prefix)
        end)
    end
  end

  def get_asset_from_work_order(work_order, prefix) do
    workorder_schedule = get_workorder_schedule!(work_order.workorder_schedule_id, prefix)
    case workorder_schedule.asset_type do
      "L" ->
        {AssetConfig.get_location(workorder_schedule.asset_id, prefix), workorder_schedule}

      "E" ->
        {AssetConfig.get_equipment(workorder_schedule.asset_id, prefix), workorder_schedule}
    end
  end


  # defp record_meter_readings(work_order, updated_work_order, prefix) do
  #   if work_order.status != "cp" and existing_work_order.status != updated_work_order.status  && updated_work_order.status == "cp" do
  #     Measurements.record_meter_readings_from_work_order(work_order, prefix)

  defp change_ticket_status(old_work_order, updated_work_order, user, prefix) do
    if updated_work_order.type == "TKT" and old_work_order.status != "cp" and updated_work_order.status == "cp" do
      work_request = Ticket.get_work_request!(updated_work_order.work_request_id, prefix)
      Ticket.update_work_request(work_request, %{"status" => "CP"}, prefix, user)
      updated_work_order
    else
      updated_work_order
    end
  end

  defp record_meter_readings(work_order, updated_work_order, prefix) do
    if work_order.status != "cp" and updated_work_order.status == "cp" do
      Measurements.record_meter_readings_from_work_order(work_order, prefix)
    else
      updated_work_order
    end
  end

  defp prevent_updating_deactivated_work_order(cs, work_order) do
    if work_order.is_deactivated do
      change_cs_to_prevent_updating_deactivated_work_order(cs, work_order)
    else
      cs
    end
  end

  defp change_cs_to_prevent_updating_deactivated_work_order(cs, work_order) do
    start_date = get_field(cs, :start_date)
    start_time = get_field(cs, :start_time)
    completed_date = get_field(cs, :completed_date)
    completed_time = get_field(cs, :completed_time)
    if start_date != nil and start_time != nil do
      cs =
            if NaiveDateTime.new!(start_date, start_time) <= work_order.deactivated_date_time do
              change(cs, %{status: "incp"})
            else
              cs
            end
      if completed_date != nil and completed_time != nil do
        if NaiveDateTime.new!(completed_date, completed_time) <= work_order.deactivated_date_time do
          change(cs, %{status: "cp"})
        else
          cs
        end
      else
        cs
      end
    else
      cs
    end
  end

  defp combine_date_time_in_attrs(date, time) when date != nil and time != nil do
    date = date
            |> String.split("-")
            |> Enum.map(&String.to_integer/1)
            |> (fn [year, month, day] -> Date.new!(year, month, day) end).()

    time = time
            |> String.split(":")
            |> Enum.map(&String.to_integer/1)
            |> (fn [hour, min, sec] -> Time.new!(hour, min, sec) end).()

    NaiveDateTime.new!(date, time)
  end

  def update_work_order_status(%WorkOrder{} = work_order, attrs, prefix, user) do
    work_order
    |> WorkOrder.changeset(attrs)
    |> update_status(work_order, user, prefix)
    |> Repo.update(prefix: prefix)
  end

  def update_work_orders(work_order_changes, prefix, user) do
    Enum.map(work_order_changes["ids"], fn id ->
      work_order = get_work_order!(id, prefix)
      {:ok, work_order} = update_work_order(work_order, Map.drop(work_order_changes, ["ids"]), prefix, user)
      work_order
    end)
  end

  def approve_work_permit(work_order_id, prefix, user) do
    work_order = get_work_order!(work_order_id, prefix)
    if work_order.workpermit_obtained ++ [user.id] == work_order.workpermit_required do
      attrs = %{"workpermit_obtained" => work_order.workpermit_obtained ++ [user.id], "status" => "wpa"}
      {:ok, updated_work_order} = update_work_order(work_order, attrs, prefix, user)
      query = from wc in WorkorderCheck, where: wc.work_order_id == ^work_order_id and wc.type == ^"WP", update: [set: [approved: true]]
      Repo.update_all(query, prefix: prefix)
      {:ok, updated_work_order}
    else
      attrs = %{"workpermit_obtained" => work_order.workpermit_obtained ++ [user.id]}
      update_work_order(work_order, attrs, prefix, user)
    end
  end

  def approve_loto(work_order_id, prefix, user) do
    work_order = get_work_order!(work_order_id, prefix)
    {:ok, updated_work_order} = update_work_order(work_order, %{"is_loto_obtained" => true, "status" => "lta"}, prefix, user)
    query = from wc in WorkorderCheck, where: wc.work_order_id == ^work_order_id and wc.type == ^"LOTO", update: [set: [approved: true]]
    Repo.update_all(query, prefix: prefix)
    update_status_track(updated_work_order, user, prefix, "lta")
  end

  def update_pre_checks(workorder_check_ids, prefix, user) do

    results =
      Enum.map(workorder_check_ids, fn id ->
        check = get_workorder_check!(id, prefix)
        {:ok, workorder_check} = update_workorder_check(check, %{"approved" => true}, prefix)
        workorder_check
      end)

    work_order = get_work_order!(List.first(results).work_order_id, prefix)
    all_pre_checks = WorkorderCheck |> where([work_order_id: ^work_order.id, type: ^"PRE"]) |> Repo.all(prefix: prefix)
    if length(all_pre_checks) == length(results) do
      update_work_order(work_order, %{"precheck_completed" => true}, prefix, user)
    end
    results
  end

  @doc """
  Deletes a work_order.

  ## Examples

      iex> delete_work_order(work_order)
      {:ok, %WorkOrder{}}

      iex> delete_work_order(work_order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work_order(%WorkOrder{} = work_order, prefix) do
    Repo.delete(work_order, prefix: prefix)
  end

  def get_site_date_time(work_order, prefix) do
    site = Repo.get!(Site, work_order.site_id, prefix: prefix)
    date_time = DateTime.now!(site.time_zone)
    NaiveDateTime.new!(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.minute, date_time.second)
  end

  def create_status_track(work_order, user, prefix) do
    case work_order.status do
      "cr" ->
            site = Repo.get!(Site, work_order.site_id, prefix: prefix)
            date_time = DateTime.now!(site.time_zone)
            date = Date.new!(date_time.year, date_time.month, date_time.day)
            time = Time.new!(date_time.hour, date_time.minute, date_time.second)
            create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => work_order.status, "user_id" => user.id, "date" => date, "time" => time}, prefix)
            {:ok, get_work_order!(work_order.id, prefix)}
      "as" ->
            site = Repo.get!(Site, work_order.site_id, prefix: prefix)
            date_time = DateTime.now!(site.time_zone)
            date = Date.new!(date_time.year, date_time.month, date_time.day)
            time = Time.new!(date_time.hour, date_time.minute, date_time.second)
            create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => "cr", "user_id" => user.id, "date" => date, "time" => time}, prefix)
            create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => work_order.status, "user_id" => user.id, "date" => date, "time" => time}, prefix)
            {:ok, get_work_order!(work_order.id, prefix)}
    end
  end

  defp status_created(cs, prefix) do
    site_id = get_field(cs, :site_id)
    site = Repo.get!(Site, site_id, prefix: prefix)
    date_time = DateTime.now!(site.time_zone)
    date = Date.new!(date_time.year, date_time.month, date_time.day)
    time = Time.new!(date_time.hour, date_time.minute, date_time.second)
    change(cs, %{status: "cr", created_date: date, created_time: time})
  end

  defp self_assign(cs, work_order, user) do
    if get_change(cs, :start_date) != nil and get_change(cs, :start_time) != nil and work_order.user_id == nil do
      change(cs, %{user_id: user.id, is_self_assigned: true})
    else
      cs
    end
  end

  defp status_assigned(cs, prefix) do
    if get_change(cs, :user_id, nil) != nil do
      site_id = get_field(cs, :site_id)
      site = Repo.get!(Site, site_id, prefix: prefix)
      date_time = DateTime.now!(site.time_zone)
      date = Date.new!(date_time.year, date_time.month, date_time.day)
      time = Time.new!(date_time.hour, date_time.minute, date_time.second)
      change(cs, %{status: "as", assigned_date: date, assigned_time: time})
    else
      cs
    end
  end

  defp status_auto_assigned(cs, work_order, prefix) do
    if get_change(cs, :user_id, nil) != nil do
      site_id = get_field(cs, :site_id)
      site = Repo.get!(Site, site_id, prefix: prefix)
      date_time = DateTime.now!(site.time_zone)
      date = Date.new!(date_time.year, date_time.month, date_time.day)
      time = Time.new!(date_time.hour, date_time.minute, date_time.second)
      update_status_track(work_order, %{id: nil}, prefix, "as")
      change(cs, %{status: "as", assigned_date: date, assigned_time: time})
    else
      cs
    end
  end

  defp status_assigned(cs, work_order, user, prefix) do
    if get_change(cs, :user_id, nil) != nil and work_order.user_id == nil do
      site = Repo.get!(Site, work_order.site_id, prefix: prefix)
      date_time = DateTime.now!(site.time_zone)
      date = Date.new!(date_time.year, date_time.month, date_time.day)
      time = Time.new!(date_time.hour, date_time.minute, date_time.second)
      update_status_track(work_order, user, prefix, "as")
      change(cs, %{status: "as", assigned_date: date, assigned_time: time})
    else
      cs
    end
  end

  defp status_reassigned(cs, work_order, user, prefix) do
    if get_change(cs, :user_id, nil) != nil and work_order.user_id != nil do
      site = Repo.get!(Site, work_order.site_id, prefix: prefix)
      date_time = DateTime.now!(site.time_zone)
      date = Date.new!(date_time.year, date_time.month, date_time.day)
      time = Time.new!(date_time.hour, date_time.minute, date_time.second)
      update_status_track(work_order, user, prefix, "reassigned")
      change(cs, %{status: "as", assigned_date: date, assigned_time: time})
    else
      cs
    end
  end

  defp status_rescheduled(cs, work_order, user, prefix) do
    if get_change(cs, :scheduled_date, nil) != nil or get_change(cs, :scheduled_time, nil) != nil do
      update_status_track(work_order, user, prefix, "rescheduled")
      cs
    else
      cs
    end
  end

  defp update_status(cs, work_order, user, prefix) do
    case get_change(cs, :status, nil) do
      "wp" ->
              update_status_track(work_order, user, prefix, "wp")
              cs
      "ltl" ->
              update_status_track(work_order, user, prefix, "ltl")
              cs
      "ip" ->
              update_status_track(work_order, user, prefix, "ip")
              cs
      "cp" ->
              update_status_track(work_order, user, prefix, "cp")
              cs
      "ltr" ->
              update_status_track(work_order, user, prefix, "ltr")
              cs
      "cn" ->
              update_status_track(work_order, user, prefix, "cn")
              cs
      "hl" ->
              update_status_track(work_order, user, prefix, "wpp")
              cs

      "ltp" ->
              update_status_track(work_order, user, prefix, "ltp")
              cs

      "wpp" ->
              update_status_track(work_order, user, prefix, "hl")
              cs

       _ ->
              cs
    end
  end


  defp update_status_track(work_order, user, prefix, status) do
    site = Repo.get!(Site, work_order.site_id, prefix: prefix)
    date_time = DateTime.now!(site.time_zone)
    date = Date.new!(date_time.year, date_time.month, date_time.day)
    time = Time.new!(date_time.hour, date_time.minute, date_time.second)
    case status do
      "reassigned" ->
          create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => status, "user_id" => user.id, "date" => date, "time" => time,
                                          "assigned_from" => work_order.user_id}, prefix)

      "rescheduled" ->
          date_time = NaiveDateTime.new!(work_order.scheduled_date, work_order.scheduled_time)
          create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => status, "user_id" => user.id, "date" => date, "time" => time,
                                          "scheduled_from" => date_time}, prefix)

       _ ->
          create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => status, "user_id" => user.id, "date" => date, "time" => time}, prefix)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work_order changes.

  ## Examples

      iex> change_work_order(work_order)
      %Ecto.Changeset{data: %WorkOrder{}}

  """
  def change_work_order(%WorkOrder{} = work_order, attrs \\ %{}) do
    WorkOrder.changeset(work_order, attrs)
  end

  alias Inconn2Service.Workorder.WorkorderTask

  @doc """
  Returns the list of workorder_tasks.

  ## Examples

      iex> list_workorder_tasks()
      [%WorkorderTask{}, ...]

  """
  def list_workorder_tasks(prefix) do
    Repo.all(WorkorderTask, prefix: prefix)
  end

  def list_work_orders_mobile(user, prefix) do

    employee =
      case user.employee_id do
        nil ->
          nil

        id ->
          Staff.get_employee!(id, prefix)
      end


    # until = Time.utc_now
    query_for_assigned = from wo in WorkOrder, where: wo.user_id == ^user.id and wo.status not in ["cp", "cn"]
    assigned_work_orders = Repo.all(query_for_assigned, prefix: prefix)

    asset_category_workorders =
      case employee do
        nil ->
          []

        employee ->
          query =
            from wo in WorkOrder,
              join: wt in WorkorderTemplate, on: wt.id == wo.workorder_template_id and wo.status not in ["cp", "cn"] and wt.asset_category_id in ^employee.skills
          Repo.all(query, prefix: prefix)
      end

    work_orders = Enum.uniq(assigned_work_orders ++ asset_category_workorders)


    Enum.map(work_orders, fn wo ->
      workorder_template = get_workorder_template!(wo.workorder_template_id, prefix)
      asset =
        case workorder_template.asset_type do
          "L" ->
            AssetConfig.get_location!(wo.asset_id, prefix)
          "E" ->
            AssetConfig.get_equipment!(wo.asset_id, prefix)
        end

      site = AssetConfig.get_site!(wo.site_id, prefix)

      user =
        case wo.user_id do
          nil ->
            nil

          id ->
            Staff.get_user!(id, prefix)
        end

      employee =
        if user != nil do
          case user.employee_id do
            nil ->
              nil

            id ->
              Staff.get_employee!(id, prefix)
          end
        else
          nil
        end

      workorder_template =
        case wo.workorder_template_id do
          nil ->
            nil

          id ->
            get_workorder_template!(id, prefix)
        end

      workorder_schedule =
        case wo.workorder_schedule_id do
          nil ->
            nil

          id ->
            get_workorder_schedule!(id, prefix)
        end

      workorder_tasks =
        list_workorder_tasks(prefix, wo.id)
        |> Enum.map(fn wot ->
          Map.put_new(wot, :task, WorkOrderConfig.get_task(wot.task_id, prefix))
        end)


      work_request =
        case wo.work_request_id do
          nil ->
            nil

          id ->
            Inconn2Service.Ticket.get_work_request!(id, prefix)
        end



      workpermit_checks =
        if workorder_template.workpermit_required do
          query = from wc in WorkorderCheck, where: wc.work_order_id == ^wo.id and wc.type == ^"WP"
          Repo.all(query, prefix: prefix)
        else
          []
        end

      loto_checks =
        if workorder_template.loto_required do
          query = from wc in WorkorderCheck, where: wc.work_order_id == ^wo.id and wc.type == ^"LOTO"
          Repo.all(query, prefix: prefix)
        else
          []
        end

      pre_checks =
        if workorder_template.pre_check_required do
          query = from wc in WorkorderCheck, where: wc.work_order_id == ^wo.id and wc.type == ^"PRE"
          Repo.all(query, prefix: prefix)
        else
          []
        end

      scheduled_date_time = NaiveDateTime.new!(wo.scheduled_date, wo.scheduled_time)

      wo
      |> Map.put_new(:asset, asset)
      |> Map.put_new(:asset_type, workorder_template.asset_type)
      |> Map.put_new(:asset_qr_code, asset.qr_code)
      |> Map.put_new(:site, site)
      |> Map.put_new(:user, user)
      |> Map.put_new(:employee, employee)
      |> Map.put_new(:workorder_template, workorder_template)
      |> Map.put_new(:workorder_schedule, workorder_schedule)
      |> Map.put_new(:workorder_tasks, workorder_tasks)
      |> Map.put_new(:workorder_tasks, workorder_tasks)
      |> Map.put_new(:workpermit_checks, workpermit_checks)
      |> Map.put_new(:loto_checks, loto_checks)
      |> Map.put_new(:pre_checks, pre_checks)
      |> Map.put_new(:work_request, work_request)
      |> Map.put_new(:scheduled_date_time, scheduled_date_time)

    end)
    |> Enum.filter(fn wo -> wo.is_deactivated != true end)
    |> Enum.sort_by(&(&1.scheduled_date_time), NaiveDateTime)

  end

  def add_stuff_to_workorder(wo, prefix) do
    workorder_template = get_workorder_template!(wo.workorder_template_id, prefix)
    asset =
      case workorder_template.asset_type do
        "L" ->
          AssetConfig.get_location!(wo.asset_id, prefix)
        "E" ->
          AssetConfig.get_equipment!(wo.asset_id, prefix)
      end

    site = AssetConfig.get_site!(wo.site_id, prefix)

    user =
      case wo.user_id do
        nil ->
          nil

        id ->
          Staff.get_user!(id, prefix)
      end

    employee =
      if user != nil do
        case user.employee_id do
          nil ->
            nil

          id ->
            Staff.get_employee!(id, prefix)
        end
      else
        nil
      end

    workorder_template =
      case wo.workorder_template_id do
        nil ->
          nil

        id ->
          get_workorder_template!(id, prefix)
      end

    workorder_schedule =
      case wo.workorder_schedule_id do
        nil ->
          nil

        id ->
          get_workorder_schedule!(id, prefix)
      end


    wo
    |> Map.put_new(:asset, asset)
    |> Map.put_new(:asset_type, workorder_template.asset_type)
    |> Map.put_new(:site, site)
    |> Map.put_new(:user, user)
    |> Map.put_new(:employee, employee)
    |> Map.put_new(:workorder_template, workorder_template)
    |> Map.put_new(:workorder_schedule, workorder_schedule)
  end

  def list_workorder_tasks(prefix, work_order_id) do
    from(t in WorkorderTask, where: t.work_order_id == ^work_order_id)
    |> Repo.all(prefix: prefix)
  end
  @doc """
  Gets a single workorder_task.

  Raises `Ecto.NoResultsError` if the Workorder task does not exist.

  ## Examples

      iex> get_workorder_task!(123)
      %WorkorderTask{}

      iex> get_workorder_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workorder_task!(id, prefix), do: Repo.get!(WorkorderTask, id, prefix: prefix)

  @doc """
  Creates a workorder_task.

  ## Examples

      iex> create_workorder_task(%{field: value})
      {:ok, %WorkorderTask{}}

      iex> create_workorder_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workorder_task(attrs \\ %{}, prefix) do
    %WorkorderTask{}
        |> WorkorderTask.changeset(attrs)
        |> validate_task_id(prefix)
        |> validate_response(prefix)
        |> Repo.insert(prefix: prefix)
  end

  defp validate_task_id(cs, prefix) do
    task_id = get_field(cs, :task_id, nil)
    if task_id != nil do
      task = Repo.get(Task, task_id, prefix: prefix)
      case task != nil do
        true -> cs
        false -> add_error(cs, :task_id, "Task ID is invalid")
      end
    else
      cs
    end
  end

  defp validate_response(cs, prefix) do
    task_id = get_field(cs, :task_id)
    response = get_field(cs, :response)
    task = Repo.get!(Task, task_id, prefix: prefix)
    if task != nil and response != nil do
      case task.task_type do
        "IO" -> validate_io(cs, response)
        "IM" -> validate_im(cs, response)
        "MT" -> validate_mt(cs, response)
        "OB" -> validate_ob(cs, response)
      end
    else
      cs
    end
  end

  defp validate_io(cs, response) do
    answer = response["answers"]
    if is_bitstring(answer) or answer == nil do
      cs
    else
      add_error(cs, :response, "answer should be string")
    end
  end

  defp validate_im(cs, response) do
    answer = response["answers"]
    if is_list(answer) or answer == nil do
      cs
    else
      add_error(cs, :response, "answer should be list")
    end
  end

  defp validate_mt(cs, response) do
    answer = response["answers"]
    if is_integer(answer) or answer == nil do
      cs
    else
      add_error(cs, :response, "answer should be integer")
    end
  end

  defp validate_ob(cs, response) do
    answer = response["answers"]
    if is_bitstring(answer) or answer == nil do
      cs
    else
      add_error(cs, :response, "answer should be string")
    end
  end


  defp auto_update_workorder_status(workorder_task, prefix, user) do
    work_order = get_work_order!(workorder_task.work_order_id, prefix)
    workorder_tasks = list_workorder_tasks(prefix, workorder_task.work_order_id)
    actual_start_length = Enum.map(workorder_tasks, fn workorder_task -> workorder_task.actual_start_time end)
                          |> Enum.filter(fn actual_start -> actual_start != nil end)
                          |> Kernel.length()
    actual_end_length = Enum.map(workorder_tasks, fn workorder_task -> workorder_task.actual_end_time end)
                        |> Enum.filter(fn actual_end -> actual_end != nil end)
                        |> Kernel.length()
    workorder_tasks_length = Kernel.length(workorder_tasks)
    case actual_start_length do
      0 ->
            {:ok, workorder_task}
      _ ->
            if (actual_start_length == workorder_tasks_length) and (actual_end_length == workorder_tasks_length) do
              attrs = %{"status" => "cp"}
              update_work_order_status(work_order, attrs, prefix, user)
              {:ok, workorder_task}
            else
              attrs = %{"status" => "ip"}
              update_work_order_status(work_order, attrs, prefix, user)
              {:ok, workorder_task}
            end
    end
  end
  @doc """
  Updates a workorder_task.

  ## Examples

      iex> update_workorder_task(workorder_task, %{field: new_value})
      {:ok, %WorkorderTask{}}

      iex> update_workorder_task(workorder_task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  defp parse_naivedatetime(nil), do: nil

  defp parse_naivedatetime(date_time) do

    [date, time] =
      case String.contains?(date_time, "T") do
        true -> String.split(date_time, "T")
        false -> String.split(date_time, " ")
      end

    [year, month, day] = String.split(date, "-")
    modified_month =
      case String.length(month) do
        1->
          "0" <> month

        _ ->
          month
      end

    modified_day =
      case String.length(day) do
        1->
          "0" <> day

        _ ->
          day
      end

    Date.new!(String.to_integer(year), String.to_integer(modified_month), String.to_integer(modified_day))
    |> NaiveDateTime.new!(Time.from_iso8601!(time))
  end

  defp update_datetime_in_attrs(attrs) do
    modified_start_time = parse_naivedatetime(attrs["actual_start_time"])
    modified_end_time = parse_naivedatetime(attrs["actual_end_time"])

    attrs
    |> Map.put("actual_start_time", modified_start_time)
    |> Map.put("actual_end_time", modified_end_time)
  end


  def update_workorder_task(%WorkorderTask{} = workorder_task, attrs, prefix, user \\ %{id: nil}) do
    modified_attrs = update_datetime_in_attrs(attrs)
    result = workorder_task
            |> WorkorderTask.changeset(modified_attrs)
            |> validate_task_id(prefix)
            |> validate_response(prefix)
            |> Repo.update(prefix: prefix)
    case result do
        {:ok, workorder_task} ->
              auto_update_workorder_status(workorder_task, prefix, user)
        _ ->
              result
    end
  end

  def update_workorder_task_from_group(%WorkorderTask{} = workorder_task, attrs, prefix) do
    workorder_task
      |> WorkorderTask.changeset(attrs)
      |> validate_task_id(prefix)
      |> validate_response(prefix)
      |> Repo.update(prefix: prefix)
  end

  def update_workorder_tasks(tasks, prefix, user \\ %{id: nil}) do
    first = List.first(tasks)
    work_order = get_work_order!(first["work_order_id"], prefix)

    result_list =
      Enum.map(tasks, fn attrs ->
        task = get_workorder_task!(attrs["id"], prefix)
        case update_workorder_task_from_group(task, attrs, prefix) do
          {:ok, _workorder_task} -> "success"
          {:error, changeset} -> {:error, changeset}
        end
      end)

    success_count = Enum.filter(result_list, fn r -> r == "success" end) |> Enum.count()
    failure_results = Enum.filter(result_list, fn r -> r != "success" end)
    error_count = length(failure_results)
    case error_count do
      0 -> update_work_order(work_order, %{"status" => "cp"}, prefix, user)
      _ -> update_work_order(work_order, %{"status" => "ip"}, prefix, user)
    end

    {:ok, %{success_count: success_count, error_count: error_count, failure_results: failure_results}}
  end

  @doc """
  Deletes a workorder_task.

  ## Examples

      iex> delete_workorder_task(workorder_task)
      {:ok, %WorkorderTask{}}

      iex> delete_workorder_task(workorder_task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workorder_task(%WorkorderTask{} = workorder_task, prefix) do
    Repo.delete(workorder_task, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workorder_task changes.

  ## Examples

      iex> change_workorder_task(workorder_task)
      %Ecto.Changeset{data: %WorkorderTask{}}

  """
  def change_workorder_task(%WorkorderTask{} = workorder_task, attrs \\ %{}) do
    WorkorderTask.changeset(workorder_task, attrs)
  end

  alias Inconn2Service.Workorder.WorkorderStatusTrack

  @doc """
  Returns the list of workorder_status_tracks.

  ## Examples

      iex> list_workorder_status_tracks()
      [%WorkorderStatusTrack{}, ...]

  """
  def list_workorder_status_tracks(prefix) do
    Repo.all(WorkorderStatusTrack, prefix: prefix)
  end

  def list_status_track_by_work_order_id(work_order_id ,prefix) do
    from(s in WorkorderStatusTrack, where: s.work_order_id == ^work_order_id)
    |> Repo.all(prefix: prefix)
  end
  @doc """
  Gets a single workorder_status_track.

  Raises `Ecto.NoResultsError` if the Workorder status track does not exist.

  ## Examples

      iex> get_workorder_status_track!(123)
      %WorkorderStatusTrack{}

      iex> get_workorder_status_track!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workorder_status_track!(id, prefix), do: Repo.get!(WorkorderStatusTrack, id, prefix: prefix)


  @doc """
  Creates a workorder_status_track.

  ## Examples

      iex> create_workorder_status_track(%{field: value})
      {:ok, %WorkorderStatusTrack{}}

      iex> create_workorder_status_track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workorder_status_track(attrs \\ %{}, prefix) do
    %WorkorderStatusTrack{}
    |> WorkorderStatusTrack.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a workorder_status_track.

  ## Examples

      iex> update_workorder_status_track(workorder_status_track, %{field: new_value})
      {:ok, %WorkorderStatusTrack{}}

      iex> update_workorder_status_track(workorder_status_track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workorder_status_track(%WorkorderStatusTrack{} = workorder_status_track, attrs, prefix) do
    workorder_status_track
    |> WorkorderStatusTrack.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a workorder_status_track.

  ## Examples

      iex> delete_workorder_status_track(workorder_status_track)
      {:ok, %WorkorderStatusTrack{}}

      iex> delete_workorder_status_track(workorder_status_track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workorder_status_track(%WorkorderStatusTrack{} = workorder_status_track, prefix) do
    Repo.delete(workorder_status_track, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workorder_status_track changes.

  ## Examples

      iex> change_workorder_status_track(workorder_status_track)
      %Ecto.Changeset{data: %WorkorderStatusTrack{}}

  """
  def change_workorder_status_track(%WorkorderStatusTrack{} = workorder_status_track, attrs \\ %{}) do
    WorkorderStatusTrack.changeset(workorder_status_track, attrs)
  end

  defp get_asset(workorder_schedule, prefix) do
    case workorder_schedule.asset_type do
      "L" ->
        AssetConfig.get_location(workorder_schedule.asset_id, prefix)
      "E" ->
        AssetConfig.get_equipment(workorder_schedule.asset_id, prefix)
    end
  end


  def work_order_creation(workorder_schedule_id, prefix, zone) do
    workorder_schedule = get_workorder_schedule!(workorder_schedule_id, prefix)
    workorder_template = get_workorder_template!(workorder_schedule.workorder_template_id, prefix)
    case workorder_template.create_new do
      "at" ->
          update_workorder_and_workorder_schedule_and_scheduler(workorder_schedule, workorder_template, prefix, zone)
      "oc" ->
          w = from(w in WorkOrder, where: w.workorder_schedule_id == ^workorder_schedule.id and (w.scheduled_date < ^workorder_schedule.next_occurrence_date) or
                                                                                                (w.scheduled_date == ^workorder_schedule.next_occurrence_date and w.scheduled_time < ^workorder_schedule.next_occurrence_time))
              |> Repo.all(prefix: prefix)
          status = Enum.map(w, fn x ->
                                  if x.status in ["cp", "ltr", "cn"] do
                                    "done"
                                  else
                                     x.status
                                  end
                                end)
          status = List.delete(Enum.uniq(status), "done")
          if length(status) == 0 do
            update_workorder_and_workorder_schedule_and_scheduler(workorder_schedule, workorder_template, prefix, zone)
          else
            nil
          end
    end
  end
  # defp update_workorder_and_workorder_schedule_and_scheduler(workorder_schedule, prefix, zone) do
  #   asset = get_asset(workorder_schedule, prefix)
  #   {:ok, work_order} = create_work_order(%{"site_id" => asset.site_id,
  #                                           "asset_id" => workorder_schedule.asset_id,
  #                                           "type" => "PRV",
  #                                           "scheduled_date" => workorder_schedule.next_occurrence_date,
  #                                           "scheduled_time" => workorder_schedule.next_occurrence_time,
  #                                           "workorder_template_id" => workorder_schedule.workorder_template_id,
  #                                           "workorder_schedule_id" => workorder_schedule.id
  #                                           }, prefix)

  #   auto_create_workorder_task(work_order, prefix)
  #   auto_create_workorder_checks(work_order, prefix)
  #   auto_assign_user(work_order, prefix)

  #   workorder_schedule_cs = change_workorder_schedule(workorder_schedule)
  #   {:ok, workorder_schedule} = Multi.new()
  #                             |> Multi.update(:next_occurrence, update_next_occurrence(workorder_schedule_cs, prefix))
  #                             |> Repo.transaction(prefix: prefix)
  #   multi = Multi.new()
  #           |> Multi.delete(:delete, Common.delete_work_scheduler_cs(workorder_schedule.next_occurrence.id))

  #   multi_insert_work_scheduler(workorder_schedule, prefix, zone, multi)
  #   |> Repo.transaction()
  # end
  # defp multi_insert_work_scheduler(workorder_schedule, prefix, zone, multi) do
  #   if workorder_schedule.next_occurrence.next_occurrence_date != nil do
  #     Multi.insert(multi, :create, Common.insert_work_scheduler_cs(%{"prefix" => prefix, "workorder_schedule_id" => workorder_schedule.next_occurrence.id, "zone" => zone}))
  #   else
  #     multi
  #   end
  # end

  defp update_workorder_and_workorder_schedule_and_scheduler(workorder_schedule, workorder_template, prefix, zone) do
    asset = get_asset(workorder_schedule, prefix)
    {:ok, work_order} = create_work_order(%{"site_id" => asset.site_id,
                                            "asset_id" => workorder_schedule.asset_id,
                                            # "asset_type" => workorder_template.asset_type,
                                            "type" => "PRV",
                                            "scheduled_date" => workorder_schedule.next_occurrence_date,
                                            "scheduled_time" => workorder_schedule.next_occurrence_time,
                                            "workorder_template_id" => workorder_schedule.workorder_template_id,
                                            "workorder_schedule_id" => workorder_schedule.id,
                                            "workpermit_required" => workorder_template.workpermit_required,
                                            "workpermit_required_from" => workorder_template.workpermit_required_from,
                                            "loto_required" => workorder_template.loto_required,
                                            "loto_approval_from_user_id" => workorder_template.loto_approval_from_user_id,
                                            "pre_check_required" => workorder_template.pre_check_required
                                            }, prefix)

    auto_create_workorder_task(work_order, prefix)
    if workorder_template.workpermit_required, do: auto_create_workorder_checks(work_order, "WP", prefix)
    if workorder_template.loto_required, do: auto_create_workorder_checks(work_order, "LOTO", prefix)
    if workorder_template.pre_check_required, do: auto_create_workorder_checks(work_order, "PRE", prefix)
    # auto_assign_user(work_order, prefix)

    deactivate_previous_work_orders(work_order, work_order.scheduled_date, work_order.scheduled_time, prefix)

    workorder_schedule_cs = change_workorder_schedule(workorder_schedule)
    {:ok, workorder_schedule} = Multi.new()
                              |> Multi.update(:next_occurrence, update_next_occurrence(workorder_schedule_cs, prefix))
                              |> Repo.transaction(prefix: prefix)
    multi = Multi.new()
            |> Multi.delete(:delete, Common.delete_work_scheduler_cs(workorder_schedule.next_occurrence.id, prefix))

    multi_insert_work_scheduler(workorder_schedule, prefix, zone, multi)
    |> Repo.transaction()
  end
  defp multi_insert_work_scheduler(workorder_schedule, prefix, zone, multi) do
    if workorder_schedule.next_occurrence.next_occurrence_date != nil do
      Multi.insert(multi, :create, Common.insert_work_scheduler_cs(%{"prefix" => prefix, "workorder_schedule_id" => workorder_schedule.next_occurrence.id, "zone" => zone}))
    else
      multi
    end
  end

  defp deactivate_previous_work_orders(work_order, scheduled_date, scheduled_time, prefix) do
    work_orders = get_work_orders_by_workorder_schedule_id(work_order.workorder_schedule_id, prefix)
                  |> Enum.filter(fn wo -> wo.status not in ["cp", "cn"] and wo.is_deactivated == false and wo.id != work_order.id end)
    date_time = NaiveDateTime.new!(scheduled_date, scheduled_time)
    Enum.map(work_orders, fn wo ->
                                change_work_order(wo, %{"is_deactivated" => true, "deactivated_date_time" => date_time})
                                |> Repo.update(prefix: prefix)
                          end)

  end

  defp auto_assign_user(work_order, prefix) do
    asset = get_asset_by_asset_id(work_order.asset_id, work_order.workorder_schedule_id, prefix)
    site_id = asset.site_id
    shift_ids = get_shifts_for_work_order(site_id, work_order.scheduled_date, work_order.scheduled_time, prefix)
    employee_ids = get_users_with_skills(asset.asset_category_id, prefix)
    matching_employee_ids = get_employees_with_shifts(site_id, shift_ids, employee_ids, work_order.scheduled_date, prefix)
    users = get_users_for_employees(matching_employee_ids, prefix)
    user = List.first(users)
    if user != nil do
      work_order
      |> WorkOrder.changeset(%{"user_id" => user.id})
      |> status_auto_assigned(work_order, prefix)
      |> Repo.update(prefix: prefix)
    else
      work_order
    end
  end

  defp get_asset_by_asset_id(asset_id, workorder_schedule_id, prefix) do
    workorder_schedule = Repo.get(WorkorderSchedule, workorder_schedule_id, prefix: prefix)
    case workorder_schedule.asset_type do
      "L" ->
        AssetConfig.get_location(asset_id, prefix)
      "E" ->
        AssetConfig.get_equipment(asset_id, prefix)
    end
  end

  defp get_shifts_for_work_order(site_id, scheduled_date, scheduled_time, prefix) do
    day = Date.day_of_week(scheduled_date)
    query = from(s in Shift,
              where: s.site_id == ^site_id and
                     s.start_date <= ^scheduled_date and s.end_date >= ^scheduled_date and
                     s.start_time <= ^scheduled_time and s.end_time >= ^scheduled_time and
                     ^day in s.applicable_days
                  )
    shifts = Repo.all(query, prefix: prefix)
    Enum.map(shifts, fn shift -> shift.id end)
  end

  defp get_users_with_skills(asset_category_id, prefix) do
    query = from(e in Employee,
              where: e.has_login_credentials == true and
                     ^asset_category_id in e.skills
                  )
    employees = Repo.all(query, prefix: prefix)
    Enum.map(employees, fn employee -> employee.id end)
  end

  defp get_employees_with_shifts(site_id, shift_ids, employee_ids, scheduled_date, prefix) do
    query = from(r in EmployeeRoster,
              where: r.site_id == ^site_id and
                     r.start_date <= ^scheduled_date and r.end_date >= ^scheduled_date and
                     r.shift_id in ^shift_ids and
                     r.employee_id in ^employee_ids
                  )
    rosters = Repo.all(query, prefix: prefix)
    Enum.map(rosters, fn roster -> roster.employee_id end)
  end

  defp get_users_for_employees(employee_ids, prefix) do
    employee_emails = Enum.map(employee_ids, fn id ->
                                          (Repo.get(Employee, id, prefix: prefix)).email
                                        end)
    from(u in User, where: u.username in ^employee_emails)
      |> Repo.all(prefix: prefix)
  end

  defp auto_create_workorder_task(work_order, prefix) do
    workorder_template = get_workorder_template(work_order.workorder_template_id, prefix)
    tasks = workorder_template.tasks
    Enum.map(tasks, fn task ->
                          start_dt = calculate_start_of_task(work_order, task["order"], prefix)
                          end_dt = calculate_end_of_task(start_dt, task["id"], prefix)
                          attrs = %{
                            "work_order_id" => work_order.id,
                            "task_id" => task["id"],
                            "sequence" => task["order"],
                            # "response" => %{"answers" => nil},
                            "expected_start_time" => start_dt,
                            "expected_end_time" => end_dt
                          }
                          create_workorder_task(attrs, prefix)
                    end)
  end

  defp auto_create_workorder_checks(work_order, check_list_type, prefix) do
    workorder_template = get_workorder_template(work_order.workorder_template_id, prefix)

    check_ids =
      case check_list_type do
        "WP" ->
          CheckListConfig.get_check_list!(workorder_template.workpermit_check_list_id, prefix).check_ids

        "LOTO" ->
          CheckListConfig.get_check_list!(workorder_template.loto_lock_check_list_id, prefix).check_ids ++ CheckListConfig.get_check_list!(workorder_template.loto_release_check_list_id, prefix).check_ids

        "PRE" ->
          CheckListConfig.get_check_list!(workorder_template.pre_check_list_id, prefix).check_ids
      end

    Enum.map(check_ids, fn check_id ->
      check = CheckListConfig.get_check!(check_id, prefix)
      attrs = %{
        "check_id" => check_id,
        "type" => check.type,
        "work_order_id" => work_order.id
      }
      create_workorder_check(attrs, prefix)
    end)
  end


  defp auto_update_workorder_task(work_order, prefix) do
    # workorder_template = get_workorder_template(work_order.workorder_template_id, prefix)
    # tasks = workorder_template.tasks
    workorder_tasks = list_workorder_tasks(prefix, work_order.id)
    Enum.map(workorder_tasks, fn workorder_task ->
                          # workorder_task = from(wt in WorkorderTask, where: wt.work_order_id == ^work_order.id and wt.sequence == ^task["order"])
                          #                  |> Repo.one(prefix: prefix)
                          start_dt = calculate_start_of_task(work_order, workorder_task.sequence, prefix)
                          end_dt = calculate_end_of_task(start_dt, workorder_task.task_id, prefix)
                          attrs = %{
                            # "work_order_id" => work_order.id,
                            # "task_id" => workorder_tasks["id"],
                            # "sequence" => task["order"],
                            # "response" => %{"answers" => nil},
                            "expected_start_time" => start_dt,
                            "expected_end_time" => end_dt
                          }
                          update_workorder_task(workorder_task, attrs, prefix)
                    end)
  end

  defp calculate_start_of_task(work_order, sequence, prefix) do
    if sequence == 1 do
      NaiveDateTime.new!(work_order.scheduled_date, work_order.scheduled_time)
    else
      previous_wt = from(wt in WorkorderTask, where: wt.work_order_id == ^work_order.id and wt.sequence == (^sequence-1))
                    |> Repo.one(prefix: prefix)
      task = WorkOrderConfig.get_task(previous_wt.task_id, prefix)
      estimated_time = task.estimated_time
      dt = previous_wt.expected_start_time
      NaiveDateTime.add(dt, estimated_time*60)
    end
  end

  defp calculate_end_of_task(start_dt, task_id, prefix) do
      task = WorkOrderConfig.get_task(task_id, prefix)
      estimated_time = task.estimated_time
      NaiveDateTime.add(start_dt, estimated_time*60)
  end


  alias Inconn2Service.Workorder.WorkorderCheck

  @doc """
  Returns the list of workorder_checks.

  ## Examples

      iex> list_workorder_checks()
      [%WorkorderCheck{}, ...]

  """
  def list_workorder_checks(prefix) do
    Repo.all(WorkorderCheck, prefix: prefix)
  end

  def list_workorder_checks_by_type(work_order_id, check_type, prefix) do
    WorkorderCheck
    |> where([type: ^check_type, work_order_id: ^work_order_id])
    |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single workorder_check.

  Raises `Ecto.NoResultsError` if the Workorder check does not exist.

  ## Examples

      iex> get_workorder_check!(123)
      %WorkorderCheck{}

      iex> get_workorder_check!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workorder_check!(id, prefix), do: Repo.get!(WorkorderCheck, id, prefix: prefix)

  @doc """
  Creates a workorder_check.

  ## Examples

      iex> create_workorder_check(%{field: value})
      {:ok, %WorkorderCheck{}}

      iex> create_workorder_check(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workorder_check(attrs \\ %{}, prefix) do
    %WorkorderCheck{}
    |> WorkorderCheck.changeset(attrs)
    |> validate_approved_by_user_id(prefix)
    |> validate_check_id(prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp validate_approved_by_user_id(cs, prefix) do
    user_id = get_change(cs, :approved_by_user_id, nil)
    if user_id != nil do
      case Repo.get(User, user_id, prefix: prefix) do
        nil ->
          add_error(cs, :user_id, "User does not exist")

        _ ->
          cs
      end
    else
      cs
    end
  end


  defp validate_check_id(cs, prefix) do
    check_id = get_change(cs, :check_id, nil)
    if check_id != nil do
      case Repo.get(Check, check_id, prefix: prefix) do
        nil ->
          add_error(cs, :check_id, "Enter valid check id")

        _ ->
          cs
      end
    end
  end

  @doc """
  Updates a workorder_check.

  ## Examples

      iex> update_workorder_check(workorder_check, %{field: new_value})
      {:ok, %WorkorderCheck{}}

      iex> update_workorder_check(workorder_check, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workorder_check(%WorkorderCheck{} = workorder_check, attrs, prefix) do
    workorder_check
    |> WorkorderCheck.changeset(attrs)
    |> validate_approved_by_user_id(prefix)
    |> validate_check_id(prefix)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a workorder_check.

  ## Examples

      iex> delete_workorder_check(workorder_check)
      {:ok, %WorkorderCheck{}}

      iex> delete_workorder_check(workorder_check)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workorder_check(%WorkorderCheck{} = workorder_check, prefix) do
    Repo.delete(workorder_check, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workorder_check changes.

  ## Examples

      iex> change_workorder_check(workorder_check)
      %Ecto.Changeset{data: %WorkorderCheck{}}

  """
  def change_workorder_check(%WorkorderCheck{} = workorder_check, attrs \\ %{}) do
    WorkorderCheck.changeset(workorder_check, attrs)
  end
end

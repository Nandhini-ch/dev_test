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
  alias Inconn2Service.AssetConfig.{Site, AssetCategory, Location, Equipment}
  alias Inconn2Service.WorkOrderConfig.TaskList
  alias Inconn2Service.WorkOrderConfig.Task
  alias Inconn2Service.CheckListConfig.CheckList
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
    |> status_created()
    |> validate_asset_category_id(prefix)
    |> validate_task_list_id(prefix)
    |> validate_task_ids(prefix)
    |> validate_estimated_time(prefix)
    |> validate_workpermit_check_list_id(prefix)
    |> validate_loto_check_list_id(prefix)
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
    task_list_id = get_field(cs, :task_list_id)
    tasks_list_of_map = get_field(cs, :tasks)
    estimated_time = get_field(cs, :estimated_time)
    task_ids_1 =  Repo.get(TaskList, task_list_id, prefix: prefix).task_ids
    task_ids_2 = Enum.map(tasks_list_of_map, fn x -> Map.fetch!(x, "id") end)
    ids = task_ids_1 ++ task_ids_2
    tasks = from(t in Task, where: t.id in ^ids ) |> Repo.all(prefix: prefix)
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
    |> validate_estimated_time(prefix)
    |> validate_workpermit_check_list_id(prefix)
    |> validate_loto_check_list_id(prefix)
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

  defp status_created(cs) do
    change(cs, status: "cr")
  end

  def status_work_permitted(%WorkorderTemplate{} = workorder_template, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(%{"status" => "wp"})
    |> Repo.update(prefix: prefix)
  end

  def status_loto_locked(%WorkorderTemplate{} = workorder_template, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(%{"status" => "ltl"})
    |> Repo.update(prefix: prefix)
  end

  def status_in_progress(%WorkorderTemplate{} = workorder_template, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(%{"status" => "ip"})
    |> Repo.update(prefix: prefix)
  end

  def status_completed(%WorkorderTemplate{} = workorder_template, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(%{"status" => "cp"})
    |> Repo.update(prefix: prefix)
  end

  def status_loto_released(%WorkorderTemplate{} = workorder_template, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(%{"status" => "ltr"})
    |> Repo.update(prefix: prefix)
  end

  def status_cancelled(%WorkorderTemplate{} = workorder_template, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(%{"status" => "cn"})
    |> Repo.update(prefix: prefix)
  end

  def status_hold(%WorkorderTemplate{} = workorder_template, prefix) do
    workorder_template
    |> WorkorderTemplate.changeset(%{"status" => "hl"})
    |> Repo.update(prefix: prefix)
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
  @doc """
  Returns the list of workorder_schedules.

  ## Examples

      iex> list_workorder_schedules()
      [%WorkorderSchedule{}, ...]

  """
  def list_workorder_schedules(prefix) do
    Repo.all(WorkorderSchedule, prefix: prefix) |> Repo.preload(:workorder_template)
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
              |> validate_config(prefix)
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

  defp validate_config(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    config = get_field(cs, :config)
    workorder_template = Repo.get(WorkorderTemplate, workorder_template_id, prefix: prefix)
    if workorder_template != nil do
      repeat_unit = workorder_template.repeat_unit
      case repeat_unit do
        "H" ->
          if Map.keys(config) == ["time"] do
            cs
          else
            add_error(cs, :config, "Config is invalid")
          end
        "D" ->
          if Map.keys(config) == ["date", "time"] do
            cs
          else
            add_error(cs, :config, "Config is invalid")
          end
        "W" ->
          if Map.keys(config) == ["day", "time"] do
            cs
          else
            add_error(cs, :config, "Config is invalid")
          end
        "M" ->
          if Map.keys(config) == ["day", "time"] do
            cs
          else
            add_error(cs, :config, "Config is invalid")
          end
        "Y" ->
          if Map.keys(config) == ["day", "month", "time"] do
            cs
          else
            add_error(cs, :config, "Config is invalid")
          end
        end
      else
        cs
      end
  end

  defp calculate_next_occurrence(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    config = get_field(cs, :config)
    workorder_template = Repo.get(WorkorderTemplate, workorder_template_id, prefix: prefix)
    if workorder_template != nil do
      applicable_start = workorder_template.applicable_start
      repeat_unit = workorder_template.repeat_unit
      case repeat_unit do
        "H" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          date = applicable_start
          change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
        "D" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          date = Enum.map(String.split(config["date"], "-"), fn x -> String.to_integer(x) end)
          date = Date.new!(Enum.at(date,0), Enum.at(date,1), Enum.at(date,2))
          change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
        "W" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          day = Date.day_of_week(applicable_start)
          if config["day"] >= day do
            day_add = config["day"] - day
            date = Date.add(applicable_start, day_add)
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          else
            day_add = 7 + config["day"] - day
            date = Date.add(applicable_start,day_add)
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          end
        "M" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          if config["day"] >= applicable_start.day do
            date = Date.new!(applicable_start.year, applicable_start.month, config["day"])
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          else
            case applicable_start.month do
              12 ->
                date = Date.new!(applicable_start.year + 1, 1, config["day"])
                change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
              _ ->
                date = Date.new!(applicable_start.year, applicable_start.month + 1, config["day"])
                change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            end
          end
        "Y" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          date = Date.new!(applicable_start.year, config["month"], config["day"])
          if Date.compare(date, applicable_start) == :lt do
              date = Date.new!(applicable_start.year + 1, config["month"], config["day"])
              change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          else
              change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          end
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
              |> validate_config(prefix)
              |> calculate_next_occurrence(prefix)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, workorder_schedule} ->
          zone = get_time_zone(workorder_schedule, prefix)
          work_scheduler = Repo.get_by!(WorkScheduler, workorder_schedule_id: workorder_schedule.id)
          Common.update_work_scheduler(work_scheduler.id, %{"prefix" => prefix, "workorder_schedule_id" => workorder_schedule.id, "zone" => zone})
          {:ok, Repo.get!(WorkorderSchedule, workorder_schedule.id, prefix: prefix) |> Repo.preload(:workorder_template)}
      _ ->
        result
    end
  end

  def update_workorder_schedule_and_scheduler(id, prefix, zone) do
    workorder_schedule = get_workorder_schedule!(id, prefix)
    workorder_schedule_cs = change_workorder_schedule(workorder_schedule)
    {:ok, workorder_schedule} = Multi.new()
                                |> Multi.update(:next_occurrence, update_next_occurrence(workorder_schedule_cs, prefix))
                                |> Repo.transaction(prefix: prefix)
    multi = Multi.new()
            |> Multi.delete(:delete, Common.delete_work_scheduler_cs(workorder_schedule.next_occurrence.id))

    multi_insert(workorder_schedule, prefix, zone, multi)
    |> Repo.transaction()
  end
  defp multi_insert(workorder_schedule, prefix, zone, multi) do
    if workorder_schedule.next_occurrence.next_occurrence_date != nil do
      Multi.insert(multi, :create, Common.insert_work_scheduler_cs(%{"prefix" => prefix, "workorder_schedule_id" => workorder_schedule.next_occurrence.id, "zone" => zone}))
    else
      multi
    end
  end


  defp update_next_occurrence(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    config = get_field(cs, :config)
    workorder_template = get_workorder_template!(workorder_template_id, prefix)
    applicable_end = workorder_template.applicable_end
    time_start = workorder_template.time_start
    time_end = workorder_template.time_end
    repeat_every = workorder_template.repeat_every
    repeat_unit = workorder_template.repeat_unit
    next_occurrence_date = get_field(cs, :next_occurrence_date)
    next_occurrence_time = get_field(cs, :next_occurrence_time)
    if next_occurrence_date != nil and next_occurrence_time != nil do
      case repeat_unit do
        "H" ->
          time = Time.add(next_occurrence_time, repeat_every*3600) |> Time.truncate(:second)
          date = next_occurrence_date
          if time >= time_start and time <= time_end do
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_before_applicable_date(applicable_end)
          else
            time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
            time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
            date = Date.add(next_occurrence_date, 1)
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_before_applicable_date(applicable_end)
          end
        "D" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          date = Date.add(next_occurrence_date, repeat_every)
          change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          |> check_before_applicable_date(applicable_end)
        "W" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          date = Date.add(next_occurrence_date, repeat_every*7)
          change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
          |> check_before_applicable_date(applicable_end)
        "M" ->
          time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
          time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
          month = next_occurrence_date.month + repeat_every
          if month > 12 do
            date = Date.new!(next_occurrence_date.year + 1, month - 12, config["day"])
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_before_applicable_date(applicable_end)
          else
            date = Date.new!(next_occurrence_date.year, month, config["day"])
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_before_applicable_date(applicable_end)
          end
        "Y" ->
            time = Enum.map(String.split(config["time"], ":"), fn x -> String.to_integer(x) end)
            time = Time.new!(Enum.at(time,0), Enum.at(time,1), Enum.at(time,2))
            date = Date.new!(next_occurrence_date.year + repeat_every, config["month"], config["day"])
            change(cs, %{next_occurrence_date: date, next_occurrence_time: time})
            |> check_before_applicable_date(applicable_end)
      end
    else
      cs
    end
  end

  defp check_before_applicable_date(cs, applicable_end) do
    next_occurrence_date = get_field(cs, :next_occurrence_date)
    case Date.compare(next_occurrence_date, applicable_end) == :gt do
      false -> cs
      true -> change(cs, %{next_occurrence_date: nil, next_occurrence_time: nil})
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workorder_schedule changes.

  ## Examples

      iex> change_workorder_schedule(workorder_schedule)
      %Ecto.Changeset{data: %WorkorderSchedule{}}

  """
  def change_workorder_schedule(%WorkorderSchedule{} = workorder_schedule, attrs \\ %{}) do
    WorkorderSchedule.changeset(workorder_schedule, attrs)
  end
end

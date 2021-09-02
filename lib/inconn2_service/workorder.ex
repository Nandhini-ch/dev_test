defmodule Inconn2Service.Workorder do
  @moduledoc """
  The Workorder context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo

  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.WorkOrderConfig.TaskList
  alias Inconn2Service.WorkOrderConfig.Task
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
    |> validate_asset_category_id(prefix)
    |> validate_task_list_id(prefix)
    |> validate_task_ids(prefix)
    |> validate_estimated_time(prefix)
    |> Repo.insert(prefix: prefix)
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
    |> validate_asset_category_id(prefix)
    |> validate_task_list_id(prefix)
    |> validate_task_ids(prefix)
    |> validate_estimated_time(prefix)
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
  def create_workorder_schedule(attrs \\ %{}, zone, prefix) do
    result = %WorkorderSchedule{}
              |> WorkorderSchedule.changeset(attrs)
              |> validate_config(prefix)
              |> calculate_next_occurance(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, workorder_schedule} ->
          Common.create_work_scheduler(%{"prefix" => prefix, "workorder_schedule_id" => workorder_schedule.id, "zone" => zone})
          {:ok, Repo.get!(WorkorderSchedule, workorder_schedule.id, prefix: prefix) |> Repo.preload(:workorder_template)}
      _ ->
        result
    end
  end

  defp validate_config(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    config = get_field(cs, :config)
    repeat_unit = get_workorder_template!(workorder_template_id, prefix).repeat_unit
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
  end

  defp calculate_next_occurance(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    config = get_field(cs, :config)
    workorder_template = get_workorder_template!(workorder_template_id, prefix)
    applicable_start = workorder_template.applicable_start
    repeat_unit = workorder_template.repeat_unit
    case repeat_unit do
      "H" ->
        time = Time.new!(config["time"], 0, 0)
        date = applicable_start
        change(cs, %{next_occurance_date: date, next_occurance_time: time})
      "D" ->
        time = Time.new!(config["time"], 0, 0)
        date = Enum.map(String.split(config["date"], "-"), fn x -> String.to_integer(x) end)
        date = Date.new!(Enum.at(date,0), Enum.at(date,1), Enum.at(date,2))
        change(cs, %{next_occurance_date: date, next_occurance_time: time})
      "W" ->
        time = Time.new!(config["time"], 0, 0)
        day = Date.day_of_week(applicable_start)
        if config["day"] >= day do
          day_add = config["day"] - day
          date = Date.add(applicable_start, day_add)
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
        else
          day_add = 7 + config["day"] - day
          date = Date.add(applicable_start,day_add)
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
        end
      "M" ->
        time = Time.new!(config["time"], 0, 0)
        if config["day"] >= applicable_start.day do
          date = Date.new!(applicable_start.year, applicable_start.month, config["day"])
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
        else
          case applicable_start.month do
            12 ->
              date = Date.new!(applicable_start.year + 1, 1, config["day"])
              change(cs, %{next_occurance_date: date, next_occurance_time: time})
            _ ->
              date = Date.new!(applicable_start.year, applicable_start.month + 1, config["day"])
              change(cs, %{next_occurance_date: date, next_occurance_time: time})
          end
        end
      "Y" ->
        time = Time.new!(config["time"], 0, 0)
        date = Date.new!(applicable_start.year, config["month"], config["day"])
        if Date.compare(date, applicable_start) == :lt do
            date = Date.new!(applicable_start.year + 1, config["month"], config["day"])
            change(cs, %{next_occurance_date: date, next_occurance_time: time})
        else
            change(cs, %{next_occurance_date: date, next_occurance_time: time})
        end

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
    workorder_schedule
    |> WorkorderSchedule.changeset(attrs)
    |> validate_config(prefix)
    |> Repo.update(prefix: prefix)
  end

  def update_workorder_schedule_and_scheduler(%WorkorderSchedule{} = workorder_schedule, prefix) do
        {:ok, workorder_schedule} = workorder_schedule
                                    |> WorkorderSchedule.changeset(%{})
                                    |> update_next_occurance(prefix)
                                    |> Repo.update(prefix: prefix)
        if workorder_schedule.next_occurance_date != nil do
            Common.update_work_scheduler(workorder_schedule.id, %{})
            {:ok, workorder_schedule}
        else
            Common.delete_work_scheduler(workorder_schedule.id)
            delete_workorder_schedule(workorder_schedule, prefix)
            {:ok, nil}
        end
  end

  defp update_next_occurance(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id)
    config = get_field(cs, :config)
    workorder_template = get_workorder_template!(workorder_template_id, prefix)
    applicable_end = workorder_template.applicable_end
    time_start = workorder_template.time_start
    time_end = workorder_template.time_end
    repeat_every = workorder_template.repeat_every
    repeat_unit = workorder_template.repeat_unit
    next_occurance_date = get_field(cs, :next_occurance_date)
    next_occurance_time = get_field(cs, :next_occurance_time)
    case repeat_unit do
      "H" ->
        time = Time.add(next_occurance_time, repeat_every*3600) |> Time.truncate(:second)
        date = next_occurance_date
        if time >= time_start and time <= time_end do
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
           |> check_before_applicable_date(applicable_end)
        else
          time = Time.new!(config["time"], 0, 0)
          date = Date.add(next_occurance_date, 1)
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
           |> check_before_applicable_date(applicable_end)
        end
      "D" ->
        time = Time.new!(config["time"], 0, 0)
        date = Date.add(next_occurance_date, repeat_every)
        change(cs, %{next_occurance_date: date, next_occurance_time: time})
         |> check_before_applicable_date(applicable_end)
      "W" ->
        time = Time.new!(config["time"], 0, 0)
        date = Date.add(next_occurance_date, repeat_every*7)
        change(cs, %{next_occurance_date: date, next_occurance_time: time})
         |> check_before_applicable_date(applicable_end)
      "M" ->
        time = Time.new!(config["time"], 0, 0)
        month = next_occurance_date.month + repeat_every
        if month > 12 do
          date = Date.new!(next_occurance_date.year + 1, month - 12, config["day"])
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
           |> check_before_applicable_date(applicable_end)
        else
          date = Date.new!(next_occurance_date.year, month, config["day"])
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
           |> check_before_applicable_date(applicable_end)
        end
      "Y" ->
          time = Time.new!(config["time"], 0, 0)
          date = Date.new!(next_occurance_date.year + repeat_every, config["month"], config["day"])
          change(cs, %{next_occurance_date: date, next_occurance_time: time})
           |> check_before_applicable_date(applicable_end)
    end
  end
  defp check_before_applicable_date(cs, applicable_end) do
    next_occurance_date = get_field(cs, :next_occurance_date)
    case Date.compare(next_occurance_date, applicable_end) == :gt do
      false -> cs
      true -> change(cs, %{next_occurance_date: nil, next_occurance_time: nil})
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

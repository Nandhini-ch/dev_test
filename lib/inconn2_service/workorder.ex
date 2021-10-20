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
  alias Inconn2Service.WorkOrderConfig.{Task, TaskList}
  alias Inconn2Service.CheckListConfig.CheckList
  alias Inconn2Service.Staff.User
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

  defp calculate_next_occurrence(cs, prefix) do
    workorder_template_id = get_field(cs, :workorder_template_id, nil)
    first_date = get_field(cs, :first_occurrence_date, nil)
    first_time = get_field(cs, :first_occurrence_time, nil)
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


  alias Inconn2Service.Workorder.WorkOrder
  @doc """
  Returns the list of work_orders.

  ## Examples

      iex> list_work_orders()
      [%WorkOrder{}, ...]

  """
  def list_work_orders(prefix) do
    Repo.all(WorkOrder, prefix: prefix)
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
  def get_work_order!(id, prefix), do: Repo.get!(WorkOrder, id, prefix: prefix)

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
              |> status_created()
              |> status_assigned()
              |> validate_site_id(prefix)
              |> validate_asset_id_workorder(prefix)
              |> validate_user_id(prefix)
              |> validate_workorder_template_id(prefix)
              |> validate_workorder_schedule_id(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, work_order} ->
          create_status_track(work_order, user, prefix)
      _ ->
        result
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
  @doc """
  Updates a work_order.

  ## Examples

      iex> update_work_order(work_order, %{field: new_value})
      {:ok, %WorkOrder{}}

      iex> update_work_order(work_order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work_order(%WorkOrder{} = work_order, attrs, prefix, user) do
    work_order
    |> WorkOrder.changeset(attrs)
    |> validate_site_id(prefix)
    |> validate_asset_id_workorder(prefix)
    |> validate_user_id(prefix)
    |> status_assigned(work_order, user, prefix)
    |> update_status(work_order, user, prefix)
    |> validate_workorder_template_id(prefix)
    |> validate_workorder_schedule_id(prefix)
    |> Repo.update(prefix: prefix)
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

  def create_status_track(work_order, user, prefix) do
    case work_order.status do
      "cr" ->
            site = Repo.get!(Site, work_order.site_id, prefix: prefix)
            date_time = DateTime.now!(site.time_zone)
            date = Date.new!(date_time.year, date_time.month, date_time.day)
            time = Time.new!(date_time.hour, date_time.minute, date_time.second)
            create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => work_order.status, "user_id" => user.id, "date" => date, "time" => time}, prefix)
            {:ok, Repo.get!(WorkOrder, work_order.id, prefix: prefix)}
      "as" ->
            site = Repo.get!(Site, work_order.site_id, prefix: prefix)
            date_time = DateTime.now!(site.time_zone)
            date = Date.new!(date_time.year, date_time.month, date_time.day)
            time = Time.new!(date_time.hour, date_time.minute, date_time.second)
            create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => "cr", "user_id" => user.id, "date" => date, "time" => time}, prefix)
            create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => work_order.status, "user_id" => user.id, "date" => date, "time" => time}, prefix)
            {:ok, Repo.get!(WorkOrder, work_order.id, prefix: prefix)}
    end
  end

  defp status_created(cs) do
    change(cs, status: "cr")
  end

  defp status_assigned(cs) do
    if get_change(cs, :user_id, nil) != nil do
      change(cs, status: "as")
    else
      cs
    end
  end
  defp status_assigned(cs, work_order, user, prefix) do
    if get_change(cs, :user_id, nil) != nil do
      update_status_track(work_order, user, prefix, "as")
      change(cs, status: "as")
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
    create_workorder_status_track(%{"work_order_id" => work_order.id, "status" => status, "user_id" => user.id, "date" => date, "time" => time}, prefix)
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
    if task_id != nil do
      task = Repo.get!(Task, task_id, prefix: prefix)
      if task != nil do
        config = task.config
        case task.task_type do
          "OB" -> validate_length(cs, :response, min: config["min_length"], max: config["max_length"])
            _ -> cs
        end
      else
        cs
      end
    else
      cs
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
  def update_workorder_task(%WorkorderTask{} = workorder_task, attrs, prefix) do
    workorder_task
    |> WorkorderTask.changeset(attrs)
    |> validate_task_id(prefix)
    |> validate_response(prefix)
    |> Repo.update(prefix: prefix)
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


  def work_order_creation(workorder_schedule_id, prefix, zone) do
    workorder_schedule = get_workorder_schedule!(workorder_schedule_id, prefix)
    workorder_template = get_workorder_template!(workorder_schedule.workorder_template_id, prefix)
    case workorder_template.create_new do
      "at" ->
          update_workorder_and_workorder_schedule_and_scheduler(workorder_schedule, prefix, zone)
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
            update_workorder_and_workorder_schedule_and_scheduler(workorder_schedule, prefix, zone)
          else
            nil
          end
    end
  end
  defp update_workorder_and_workorder_schedule_and_scheduler(workorder_schedule, prefix, zone) do
    create_work_order(%{"asset_id" => workorder_schedule.asset_id,
                        "type" => "PRV",
                        "scheduled_date" => workorder_schedule.next_occurrence_date,
                        "scheduled_time" => workorder_schedule.next_occurrence_time,
                        "workorder_template_id" => workorder_schedule.workorder_template_id,
                        "workorder_schedule_id" => workorder_schedule.id
                        }, prefix)

    workorder_schedule_cs = change_workorder_schedule(workorder_schedule)
    {:ok, workorder_schedule} = Multi.new()
                              |> Multi.update(:next_occurrence, update_next_occurrence(workorder_schedule_cs, prefix))
                              |> Repo.transaction(prefix: prefix)
    multi = Multi.new()
            |> Multi.delete(:delete, Common.delete_work_scheduler_cs(workorder_schedule.next_occurrence.id))

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

end

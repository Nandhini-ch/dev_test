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

  #defp validate_estimated_time(cs, prefix) do
  #  task_list_id = get_change(cs, :task_list_id, nil)
  #  tasks_list_of_map = get_change(cs, :tasks, nil)
  #  estimated_time = get_change(cs, :estimated_time, nil)
  #  if estimated_time != nil do
  #    cond do
  #      task_list_id != nil and tasks_list_of_map != nil ->
  #            task_list = Repo.get(TaskList, task_list_id, prefix: prefix)
  #            task_ids_1 = task_list.task_ids
  #            task_ids_2 = Enum.map(tasks_list_of_map, fn x -> Map.fetch!(x, "id") end)
  #            ids = task_ids_1 ++ task_ids_2
  #      task_list_id != nil and  tasks_list_of_map == nil ->
  #            task_list = Repo.get(TaskList, task_list_id, prefix: prefix)
  #            ids = task_list.task_ids
  #      task_list_id == nil and  tasks_list_of_map != nil ->
  #            ids = Enum.map(tasks_list_of_map, fn x -> Map.fetch!(x, "id") end)
  #      task_list_id == nil and tasks_list_of_map == nil ->
  #            task_list_id = get_field(cs, :task_list_id)
  #            tasks_list_of_map = get_field(cs, :tasks)
  #            task_list = Repo.get(TaskList, task_list_id, prefix: prefix)
  #            task_ids_1 = task_list.task_ids
  #            task_ids_2 = Enum.map(tasks_list_of_map, fn x -> Map.fetch!(x, "id") end)
  #            ids = task_ids_1 ++ task_ids_2
  #    end
  #    tasks = from(t in Task, where: t.id in ^ids ) |> Repo.all(prefix: prefix)
  #    estimated_time_list = Enum.map(tasks, fn x -> x.estimated_time end)
  #    estimated_time_of_all_tasks = Enum.reduce(estimated_time_list, fn x, acc -> x + acc end)
  #      if estimated_time >= estimated_time_of_all_tasks do
  #        cs
  #      else
  #        add_error(cs, :estimated_time, "Estimated time is less than total time of all the tasks")
  #      end
  #  end
  #end

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
end

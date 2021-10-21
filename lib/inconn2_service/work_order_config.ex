defmodule Inconn2Service.WorkOrderConfig do
  @moduledoc """
  The WorkOrderConfig context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo

  alias Inconn2Service.WorkOrderConfig.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks(prefix) do
    Repo.all(Task, prefix: prefix)
  end

  def list_tasks(query_params, prefix) do
    Task
    |> Repo.add_active_filter(query_params)
    |> Repo.all(prefix: prefix)
  end

  def search_tasks(label, prefix) do
    if String.length(label) < 3 do
      []
    else
      search_text = label <> "%"

      from(t in Task, where: ilike(t.label, ^search_text), order_by: t.label)
      |> Repo.all(prefix: prefix)
    end
  end
  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Business type does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id, prefix), do: Repo.get!(Task, id, prefix: prefix)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}, prefix) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs, prefix) do
    task
    |> Task.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task, prefix) do
    Repo.delete(task, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end


  alias Inconn2Service.WorkOrderConfig.TaskList
  alias Inconn2Service.AssetConfig.AssetCategory
  @doc """
  Returns the list of task_lists.

  ## Examples

      iex> list_task_lists()
      [%TaskList{}, ...]

  """
  def list_task_lists(prefix) do
    Repo.all(TaskList, prefix: prefix)
  end

  def list_task_lists(query_params, prefix) do
    TaskList
    |> Repo.add_active_filter(query_params)
    |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single task_list.

  Raises `Ecto.NoResultsError` if the Business type does not exist.

  ## Examples

      iex> get_task_list!(123)
      %TaskList{}

      iex> get_task_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task_list!(id, prefix), do: Repo.get!(TaskList, id, prefix: prefix)

  @doc """
  Creates a task_list.

  ## Examples

      iex> create_task_list(%{field: value})
      {:ok, %TaskList{}}

      iex> create_task_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task_list(attrs \\ %{}, prefix) do
    %TaskList{}
    |> TaskList.changeset(attrs)
    |> validate_task_ids(prefix)
    |> validate_asset_category_id(prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp validate_task_ids(cs, prefix) do
    ids = get_change(cs, :task_ids, nil)
    if ids != nil do
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
  @doc """
  Updates a task_list.

  ## Examples

      iex> update_task_list(task_list, %{field: new_value})
      {:ok, %TaskList{}}

      iex> update_task_list(task_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """


  def update_task_list(%TaskList{} = task_list, attrs, prefix) do
    task_list
    |> TaskList.changeset(attrs)
    |> validate_task_ids(prefix)
    |> validate_asset_category_id(prefix)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a task_list.

  ## Examples

      iex> delete_task_list(task_list)
      {:ok, %TaskList{}}

      iex> delete_task_list(task_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task_list(%TaskList{} = task_list, prefix) do
    Repo.delete(task_list, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task_list changes.

  ## Examples

      iex> change_task_list(task_list)
      %Ecto.Changeset{data: %TaskList{}}

  """
  def change_task_list(%TaskList{} = task_list, attrs \\ %{}) do
    TaskList.changeset(task_list, attrs)
  end
end

defmodule Inconn2Service.WorkOrderConfig do
  @moduledoc """
  The WorkOrderConfig context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Multi
  alias Inconn2Service.Repo

  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.WorkOrderConfig.{Task, TaskTasklist, TaskList}
  import Inconn2Service.Util.DeleteManager
  # import Inconn2Service.Util.IndexQueries
  # import Inconn2Service.Util.HelpersFunctions

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks(prefix) do
    Repo.add_active_filter(Task)
    |> Repo.all(prefix: prefix)
  end

  def list_tasks(query_params, prefix) do
    query = from q in Task
    Enum.reduce(query_params, query, fn
      {"master_task_type_id", master_task_type_id}, query -> from q in query, where: q.master_task_type_id == ^master_task_type_id
      _, query -> query
    end)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

  def search_tasks(label, prefix) do
    if String.length(label) < 3 do
      []
    else
      search_text = label <> "%"

      from(t in Task, where: ilike(t.label, ^search_text), order_by: t.label)
      |> Repo.add_active_filter()
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
  def get_task(id, prefix), do: Repo.get(Task, id, prefix: prefix)

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

  def create_task_for_multi(_, _, attrs \\ %{}, prefix) do
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
  # def delete_task(%Task{} = task, prefix) do
  #   task
  #   |> Task.changeset(%{"active" => false})
  #   |> Repo.update(prefix: prefix)
  # end


  def delete_task(%Task{} = task, prefix) do
    cond do
      has_task_tasklistt?(task, prefix) ->
        {:could_not_delete,
        "Cannot Delete because there are Task list assocaited"}

      true ->
        update_task(task, %{"active" => false}, prefix)
        {:deleted, "Task was deleted"}
    end
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
    Repo.add_active_filter(TaskList)
    |> Repo.all(prefix: prefix)
  end

  def list_tasks_for_task_lists(task_list_id, prefix) do
    from(ttl in TaskTasklist, where: ttl.task_list_id == ^task_list_id)
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:task)
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
    result = %TaskList{}
              |> TaskList.changeset(attrs)
              |> validate_asset_category_id(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, task_list} ->
        Enum.map(attrs["tasks"], fn task ->
          create_task_tasklist_for_existing_task(task["task_id"], task["sequence"], task_list.id, prefix)
        end)
        result
      _ ->
        result
    end
  end

  def create_task_list_with_tasks(attrs \\ %{}, prefix) do
    case task_list_transactions_for_create(attrs, prefix) do
      {:ok, %{create_or_update_task_list: task_list}} -> {:ok, task_list}
      _ -> {:error, "failure"}
    end
  end

  def task_list_transactions_for_create(attrs, prefix) do
    Multi.new()
    |> Multi.run(:create_or_update_task_list, WorkOrderConfig, :create_task_list_for_multi, [attrs, prefix])
    |> Multi.run(:link_existing_tasks, WorkOrderConfig, :link_existing_tasks, [attrs["tasks"], prefix])
    |> Multi.run(:create_and_link_new_tasks, WorkOrderConfig, :create_and_link_new_tasks, [attrs["new_tasks"], prefix])
    |> Repo.transaction()
  end

  def create_task_list_for_multi(_, _, attrs \\ %{}, prefix) do
    %TaskList{}
    |> TaskList.changeset(attrs)
    |> validate_asset_category_id(prefix)
    |> Repo.insert(prefix: prefix)
  end

  def link_existing_tasks(_, %{create_or_update_task_list: task_list}, nil, _), do: {:ok, %{create_or_update_task_list: task_list}}

  def link_existing_tasks(_, %{create_or_update_task_list: task_list}, tasks, prefix) do
    failed_task_tasklist =
        Stream.map(tasks, fn task -> create_task_tasklist_for_existing_task(task["task_id"], task["sequence"], task_list.id, prefix) end)
        |> Enum.filter(fn result ->
          :ok != Tuple.to_list(result) |> List.first()
        end)
    case length(failed_task_tasklist) do
      0 -> {:ok, %{create_or_update_task_list: task_list}}
      _ -> {:error, "failure"}
    end
  end

  defp create_task_tasklist_for_existing_task(task_id, sequence, task_list_id, prefix) do
    %{
      "task_id" => task_id,
      "task_list_id" => task_list_id,
      "sequence" => sequence
    }
    |> create_task_tasklist(prefix)
  end

  def create_and_link_new_tasks(_, %{create_or_update_task_list: task_list}, nil, _),do: {:ok, %{create_or_update_task_list: task_list}}

  def create_and_link_new_tasks(_, %{create_or_update_task_list: task_list}, new_tasks, prefix) do
    failed_task_transactions =
        Stream.map(new_tasks, fn task_attrs -> create_new_task_and_task_tasklist(task_attrs, task_list, prefix) end)
        |> Enum.filter(fn result ->
                        :ok != Tuple.to_list(result) |> List.first()
                      end)
    case length(failed_task_transactions) do
      0 -> {:ok, %{create_or_update_task_list: task_list}}
      _ -> {:error, "failure"}
    end
  end

  defp create_new_task_and_task_tasklist(task_attrs, task_list, prefix) do
    Multi.new()
    |> Multi.insert(:create_task, Task.changeset(%Task{}, task_attrs), prefix: prefix)
    |> Multi.insert(:create_task_tasklist,
                    fn %{create_task: task} ->
                      TaskTasklist.changeset(%TaskTasklist{}, %{"task_id" => task.id, "task_list_id" => task_list.id, "sequence" => task_attrs["sequence"]})
                    end,
                    prefix: prefix)
    |> Repo.transaction()
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
      |> validate_asset_category_id(prefix)
      |> Repo.update(prefix: prefix)
  end

  def update_task_list_with_tasks(%TaskList{} = task_list, attrs \\ %{}, prefix) do
    case task_list_transactions_for_update(task_list, attrs, prefix) do
      {:ok, %{create_or_update_task_list: task_list}} -> {:ok, task_list}
      _ -> {:error, "failure"}
    end
  end

  defp task_list_transactions_for_update(task_list, attrs, prefix) do
    Multi.new()
    |> Multi.run(:create_or_update_task_list, WorkOrderConfig, :update_task_list_for_multi, [task_list, attrs, prefix])
    |> Multi.run(:delete_task_tasklist, WorkOrderConfig, :delete_task_tasklist, [prefix])
    |> Multi.run(:link_existing_tasks, WorkOrderConfig, :link_existing_tasks, [attrs["tasks"], prefix])
    |> Multi.run(:create_and_link_new_tasks, WorkOrderConfig, :create_and_link_new_tasks, [attrs["new_tasks"], prefix])
    |> Repo.transaction()
  end

  def update_task_list_for_multi(_, _, %TaskList{} = task_list, attrs \\ %{}, prefix) do
    task_list
      |> TaskList.changeset(attrs)
      |> validate_asset_category_id(prefix)
      |> Repo.update(prefix: prefix)
  end

  def delete_task_tasklist(_, %{create_or_update_task_list: task_list}, prefix) do
    deleted_task_tasklist = delete_from_intermediate_task_table(task_list, prefix)
                            |> Enum.filter(fn result ->
                              :ok != Tuple.to_list(result) |> List.first()
                            end)
    case length(deleted_task_tasklist) do
      0 -> {:ok, %{create_or_update_task_list: task_list}}
      _ -> {:error, "failure"}
    end
  end

  defp delete_from_intermediate_task_table(task_list, prefix) do
    from(ttl in TaskTasklist, where: ttl.task_list_id == ^ task_list.id)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn ttl -> delete_task_tasklist(ttl, prefix) end)
  end

  def update_active_status_for_task_list(%TaskList{} = task_list, attrs, prefix) do
    task_list
    |> TaskList.changeset(attrs)
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
  # def delete_task_list(%TaskList{} = task_list, prefix) do
  #   task_list
  #     |> TaskList.changeset(%{"active" => false})
  #     |> Repo.update(prefix: prefix)
  # end

  def delete_task_list(%TaskList{} = task_list, prefix) do
    cond do
      has_workorder_template?(task_list, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are Equipments associated with it"
      }

      true ->
        update_task_list(task_list, %{"active" => false}, prefix)
          {:deleted,
             "The Task List was disabled"
           }
    end
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

  alias Inconn2Service.WorkOrderConfig.MasterTaskType

  @doc """
  Returns the list of master_task_types.

  ## Examples

      iex> list_master_task_types()
      [%MasterTaskType{}, ...]

  """
  def list_master_task_types(prefix) do
    Repo.all(MasterTaskType, prefix: prefix)
  end

  @doc """
  Gets a single master_task_type.

  Raises `Ecto.NoResultsError` if the Master task type does not exist.

  ## Examples

      iex> get_master_task_type!(123)
      %MasterTaskType{}

      iex> get_master_task_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_master_task_type!(id, prefix), do: Repo.get!(MasterTaskType, id, prefix: prefix)

  @doc """
  Creates a master_task_type.

  ## Examples

      iex> create_master_task_type(%{field: value})
      {:ok, %MasterTaskType{}}

      iex> create_master_task_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_master_task_type(attrs \\ %{}, prefix) do
    %MasterTaskType{}
    |> MasterTaskType.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a master_task_type.

  ## Examples

      iex> update_master_task_type(master_task_type, %{field: new_value})
      {:ok, %MasterTaskType{}}

      iex> update_master_task_type(master_task_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_master_task_type(%MasterTaskType{} = master_task_type, attrs, prefix) do
    master_task_type
    |> MasterTaskType.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a master_task_type.

  ## Examples

      iex> delete_master_task_type(master_task_type)
      {:ok, %MasterTaskType{}}

      iex> delete_master_task_type(master_task_type)
      {:error, %Ecto.Changeset{}}

  """
  # def delete_master_task_type(%MasterTaskType{} = master_task_type, prefix) do
  #   Repo.delete(master_task_type, prefix: prefix)
  # end

  def delete_master_task_type(%MasterTaskType{} = master_task_type, prefix) do
    cond do
      has_task?(master_task_type, prefix) ->
        {:could_not_delete,
        "Cannot Delete because there are Task assocaited"}

      true ->
        update_master_task_type(master_task_type, %{"active" => false}, prefix)
        {:deleted, "Master Task Type was deleted"}
    end
  end


  @doc """
  Returns an `%Ecto.Changeset{}` for tracking master_task_type changes.

  ## Examples

      iex> change_master_task_type(master_task_type)
      %Ecto.Changeset{data: %MasterTaskType{}}

  """
  def change_master_task_type(%MasterTaskType{} = master_task_type, attrs \\ %{}) do
    MasterTaskType.changeset(master_task_type, attrs)
  end

  alias Inconn2Service.WorkOrderConfig.TaskTasklist

  @doc """
  Returns the list of task_tasklists.

  ## Examples

      iex> list_task_tasklists()
      [%TaskTasklist{}, ...]

  """
  def list_task_tasklists(prefix) do
    Repo.all(TaskTasklist, prefix: prefix)
  end

  @doc """
  Gets a single task_tasklist.

  Raises `Ecto.NoResultsError` if the Task tasklist does not exist.

  ## Examples

      iex> get_task_tasklist!(123)
      %TaskTasklist{}

      iex> get_task_tasklist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task_tasklist!(id, prefix), do: Repo.get!(TaskTasklist, id, prefix: prefix)

  @doc """
  Creates a task_tasklist.

  ## Examples

      iex> create_task_tasklist(%{field: value})
      {:ok, %TaskTasklist{}}

      iex> create_task_tasklist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task_tasklist(attrs \\ %{}, prefix) do
    %TaskTasklist{}
    |> TaskTasklist.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a task_tasklist.

  ## Examples

      iex> update_task_tasklist(task_tasklist, %{field: new_value})
      {:ok, %TaskTasklist{}}

      iex> update_task_tasklist(task_tasklist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task_tasklist(%TaskTasklist{} = task_tasklist, attrs, prefix) do
    task_tasklist
    |> TaskTasklist.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a task_tasklist.

  ## Examples

      iex> delete_task_tasklist(task_tasklist)
      {:ok, %TaskTasklist{}}

      iex> delete_task_tasklist(task_tasklist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task_tasklist(%TaskTasklist{} = task_tasklist, prefix) do
    Repo.delete(task_tasklist, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task_tasklist changes.

  ## Examples

      iex> change_task_tasklist(task_tasklist)
      %Ecto.Changeset{data: %TaskTasklist{}}

  """
  def change_task_tasklist(%TaskTasklist{} = task_tasklist, attrs \\ %{}) do
    TaskTasklist.changeset(task_tasklist, attrs)
  end
end

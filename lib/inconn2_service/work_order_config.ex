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

  def list_tasks(prefix) do
    Repo.add_active_filter(Task)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_tasks(query_params, prefix) do
    query = from q in Task
    Enum.reduce(query_params, query, fn
      {"master_task_type_id", master_task_type_id}, query -> from q in query, where: q.master_task_type_id == ^master_task_type_id
      _, query -> query
    end)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
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

  def get_task!(id, prefix), do: Repo.get!(Task, id, prefix: prefix)
  def get_task(id, prefix), do: Repo.get(Task, id, prefix: prefix)

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

  def update_task(%Task{} = task, attrs, prefix) do
    task
    |> Task.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

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

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end


  alias Inconn2Service.WorkOrderConfig.TaskList
  alias Inconn2Service.AssetConfig.AssetCategory

  def list_task_lists(prefix) do
    Repo.add_active_filter(TaskList)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn tl -> preload_tasks(tl, prefix) end)
    |> Repo.sort_by_id()
  end

  def list_tasks_for_task_lists(task_list_id, prefix) do
    from(ttl in TaskTasklist, where: ttl.task_list_id == ^task_list_id)
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:task)
    |> Repo.sort_by_id()
  end

  def get_task_list!(id, prefix), do: Repo.get!(TaskList, id, prefix: prefix) |> preload_tasks(prefix)

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
      {:ok, %{create_or_update_task_list: task_list}} -> {:ok, task_list} |> preload_tasks(prefix)
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


  def update_task_list(%TaskList{} = task_list, attrs, prefix) do
    task_list
      |> TaskList.changeset(attrs)
      |> validate_asset_category_id(prefix)
      |> Repo.update(prefix: prefix)
      |> preload_tasks(prefix)
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


  # def delete_task_list(%TaskList{} = task_list, prefix) do
  #   task_list
  #     |> TaskList.changeset(%{"active" => false})
  #     |> Repo.update(prefix: prefix)
  # end

  def delete_task_list(%TaskList{} = task_list, prefix) do
    cond do
      has_workorder_template?(task_list, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are Workorder Template associated with it"
      }

      true ->
        update_task_list(task_list, %{"active" => false}, prefix)
          {:deleted,
             "The Task List was deleted"
           }
    end
  end

  def change_task_list(%TaskList{} = task_list, attrs \\ %{}) do
    TaskList.changeset(task_list, attrs)
  end

  alias Inconn2Service.WorkOrderConfig.MasterTaskType

  def list_master_task_types(prefix) do
    MasterTaskType
    |>Repo.add_active_filter
    |>Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def get_master_task_type!(id, prefix), do: Repo.get!(MasterTaskType, id, prefix: prefix)

  def create_master_task_type(attrs \\ %{}, prefix) do
    %MasterTaskType{}
    |> MasterTaskType.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_master_task_type(%MasterTaskType{} = master_task_type, attrs, prefix) do
    master_task_type
    |> MasterTaskType.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

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

  def change_master_task_type(%MasterTaskType{} = master_task_type, attrs \\ %{}) do
    MasterTaskType.changeset(master_task_type, attrs)
  end

  alias Inconn2Service.WorkOrderConfig.TaskTasklist

  def list_task_tasklists(prefix) do
    Repo.all(TaskTasklist, prefix: prefix)
  end

  def get_task_tasklist!(id, prefix), do: Repo.get!(TaskTasklist, id, prefix: prefix)

  def create_task_tasklist(attrs \\ %{}, prefix) do
    %TaskTasklist{}
    |> TaskTasklist.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_task_tasklist(%TaskTasklist{} = task_tasklist, attrs, prefix) do
    task_tasklist
    |> TaskTasklist.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_task_tasklist(%TaskTasklist{} = task_tasklist, prefix) do
    Repo.delete(task_tasklist, prefix: prefix)
  end

  def change_task_tasklist(%TaskTasklist{} = task_tasklist, attrs \\ %{}) do
    TaskTasklist.changeset(task_tasklist, attrs)
  end

  defp preload_tasks({:ok, task_list}, prefix), do: {:ok, preload_tasks(task_list, prefix)}
  defp preload_tasks({:error, reason}, _prefix), do: {:error, reason}

  defp preload_tasks(%TaskList{} = task_list, prefix) do
    Map.put(
            task_list,
            :task_tasklists,
            list_tasks_for_task_lists(task_list.id, prefix)
            )
  end

end

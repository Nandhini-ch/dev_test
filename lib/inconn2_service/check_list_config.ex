defmodule Inconn2Service.CheckListConfig do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  import Inconn2Service.Util.DeleteManager
  import Inconn2Service.Util.IndexQueries
  # import Inconn2Service.Util.HelpersFunctions

  alias Inconn2Service.Repo
  alias Inconn2Service.CheckListConfig.{Check, CheckList, CheckType}

  #Context functions for CheckType
  def list_check_types(prefix) do
    Repo.all(Repo.add_active_filter(CheckType), prefix: prefix)
  end

  def get_check_type!(id, prefix), do: Repo.get!(CheckType, id, prefix: prefix)
  def get_check_type(id, prefix), do: Repo.get(CheckType, id, prefix: prefix)

  def create_check_type(attrs \\ %{}, prefix) do
    %CheckType{}
    |> CheckType.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_check_type(%CheckType{} = check_type, attrs, prefix) do
    check_type
    |> CheckType.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_check_type(%CheckType{} = check_type, prefix) do
    cond do
      has_check?(check_type, prefix) ->
        {:could_not_delete,
        "Cannot Delete because there are Check assocaited"}

      true ->
        update_check_type(check_type, %{"active" => false}, prefix)
        {:deleted, "Check type was deleted"}
    end
  end

  def change_check_type(%CheckType{} = check_type, attrs \\ %{}) do
    CheckType.changeset(check_type, attrs)
  end

  #Context function for Check
  def list_checks(query_params, prefix) do
    check_query(Check, query_params) |> Repo.add_active_filter() |> Repo.all(prefix: prefix)
  end

  def get_check!(id, prefix), do: Repo.get!(Check, id, prefix: prefix) |> Repo.preload(:check_type)
  def get_check(id, prefix), do: Repo.get(Check, id, prefix: prefix) |> Repo.preload(:check_type)

  def create_check(attrs \\ %{}, prefix) do
    %Check{}
    |> Check.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_check_type()
  end

  def update_check(%Check{} = check, attrs, prefix) do
    check
    |> Check.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_check_type()
  end

  def delete_check(%Check{} = check, prefix), do: update_check(check, %{"active" => false}, prefix)

  # function commented because soft delet was implemented with same function name
  # def delete_check(%Check{} = check, prefix) do
  #   Repo.delete(check, prefix: prefix)
  # end

  def change_check(%Check{} = check, attrs \\ %{}) do
    Check.changeset(check, attrs)
  end

  #Context functions for CheckList
  def list_check_lists(prefix) do
    Repo.all(Repo.add_active_filter(CheckList), prefix: prefix)
  end

  def get_check_list!(id, prefix), do: Repo.get!(CheckList, id, prefix: prefix) |> preload_checks(prefix)
  def get_check_list(id, prefix), do: Repo.get(CheckList, id, prefix: prefix) |> preload_checks(prefix)

  def create_check_list(attrs \\ %{}, prefix) do
    %CheckList{}
    |> CheckList.changeset(create_attrs_with_new_check_ids(attrs, prefix))
    |> validate_check_ids(prefix)
    |> validate_existing_for_pre(prefix)
    |> Repo.insert(prefix: prefix)
    |> preload_checks(prefix)
  end

  def get_pre_check_list(site_id, prefix) do
    from(cl in CheckList, where: cl.type == "PRE" and cl.site_id == ^site_id) |> Repo.one(prefix: prefix)
  end

  def update_check_list(%CheckList{} = check_list, attrs, prefix) do
    check_list
    |> CheckList.changeset(attrs)
    |> validate_check_ids(prefix)
    |> Repo.update(prefix: prefix)
    |> preload_checks(prefix)
  end

  # def delete_check_list(%CheckList{} = check_list, prefix), do: update_check_list(check_list, %{"active" => false}, prefix)

  def delete_check_list(%CheckList{} = check_list, prefix) do
    cond do
      has_workorder_template?(check_list, prefix) ->
        {:could_not_delete,
        "Cannot Delete because there are workorder templates associated"}

      true ->
        update_check_list(check_list, %{"active" => false}, prefix)
        {:deleted, "Check list was deleted"}
    end
  end

  # function commented because soft delet was implemented with same function name
  # def delete_check_list(%CheckList{} = check_list, prefix) do
  #   Repo.delete(check_list, prefix: prefix)
  # end

  def change_check_list(%CheckList{} = check_list, attrs \\ %{}) do
    CheckList.changeset(check_list, attrs)
  end

  defp validate_existing_for_pre(cs, prefix) do
    site_id = get_field(cs, :site_id, nil)
    cond do
      !is_nil(site_id) and !is_nil(get_pre_check_list(site_id, prefix)) -> add_error(cs, :site_id, "A PRE Check list is already existing")
      true -> cs
    end
  end

  defp validate_check_ids(cs, prefix) do
    ids = get_change(cs, :check_ids, nil)
    checks = from(c in Check, where: c.id in ^ids) |> Repo.all(prefix: prefix)
    cond do
      !is_nil(ids) and length(ids) != length(checks) -> add_error(cs, :check_ids, "Check IDs are invalid")
      true -> cs
    end
  end

  defp create_attrs_with_new_check_ids(attrs, prefix) do
    new_check_ids = get_new_check_ids(attrs["new_checks"], prefix)
    Map.put(attrs, "check_ids", attrs["check_ids"] ++ new_check_ids)
  end

  defp preload_checks({:ok, check_list}, prefix), do: {:ok, preload_checks(check_list, prefix)}
  defp preload_checks({:error, reason}, _prefix), do: {:error, reason}

  defp preload_checks(check_list, prefix) do
    Map.put(check_list, :checks, Enum.map(check_list.check_ids, fn id -> get_check(id, prefix) end) |> Enum.filter(fn c -> c != nil && c.active end))
  end

  defp preload_check_type({:ok, check}), do: {:ok, check |> Repo.preload(:check_type)}
  defp preload_check_type(result), do: result

  defp get_new_check_ids(nil, _prefix), do: []
  defp get_new_check_ids(checks, prefix), do: Stream.map(checks, fn c -> create_check(c, prefix) end) |> Enum.map(fn {:ok, check} -> check.id end)
end

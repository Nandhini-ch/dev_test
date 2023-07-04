defmodule Inconn2Service.Reapportion do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  import Inconn2Service.Util.IndexQueries
  alias Inconn2Service.Repo

  alias Inconn2Service.Staff
  alias Inconn2Service.Workorder
  alias Inconn2Service.Reapportion.ReassignRescheduleRequest

  # @spec list_reassign_reschedule_requests(any) :: any
  def list_reassign_reschedule_requests(prefix) do
    Repo.all(ReassignRescheduleRequest, prefix: prefix)
    |> Stream.map(fn rrr -> set_asset_name(rrr, prefix) end)
    |> Stream.map(fn rrr -> get_requester_name(rrr, prefix) end)
    |> Stream.map(fn rrr -> get_reports_name(rrr, prefix) end)
    |> Enum.map(fn rrr -> get_reassign_name(rrr, prefix) end)
  end

  def list_reassign_reschedule_requests_to_be_approved(prefix, user, query_params) do
    # employee = Staff.get_employee_from_user(user.employee_id, prefix)
    case user.employee_id do
      nil -> []
      _ -> get_reassign_reschedule_requests_to_be_approved(user, query_params, prefix)
    end
  end

  defp get_reassign_reschedule_requests_to_be_approved(user, query_params, prefix) do
    from(rrr in ReassignRescheduleRequest, where: rrr.reports_to_user_id == ^user.id and rrr.status == "PD")
    |> reassign_reschedule_query(query_params)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn rrr -> set_asset_name(rrr, prefix) end)
    |> Stream.map(fn rrr -> get_requester_name(rrr, prefix) end)
    |> Stream.map(fn rrr -> get_reports_name(rrr, prefix) end)
    |> Enum.map(fn rrr -> get_reassign_name(rrr, prefix) end)
  end

  def list_reassign_reschedule_requests_pending(prefix, user, query_params) do
    from(rrr in ReassignRescheduleRequest, where: rrr.requester_user_id == ^user.id)
    |> reassign_reschedule_query(query_params)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn rrr -> set_asset_name(rrr, prefix) end)
    |> Stream.map(fn rrr -> get_requester_name(rrr, prefix) end)
    |> Stream.map(fn rrr -> get_reports_name(rrr, prefix) end)
    |> Enum.map(fn rrr -> get_reassign_name(rrr, prefix) end)
  end

  defp set_asset_name(request, prefix) do
    work_order = Workorder.get_work_order!(request.work_order_id, prefix)
    Map.put(request, :asset_name, work_order.asset_name)
    |> Map.put(:type, work_order.type)
    |> Map.put(:frequency, work_order.frequency)
    |> Map.put(:scheduled_date, work_order.scheduled_date)
    |> Map.put(:scheduled_time, work_order.scheduled_time)
  end

  defp get_requester_name(request, prefix) do
    Map.put(request, :requester, Staff.get_user!(request.requester_user_id, prefix))
  end

  defp get_reports_name(request, prefix) do
    case request.reports_to_user_id do
      nil ->
        Map.put(request, :reports_to, nil)
      id ->
        Map.put(request, :reports_to, Staff.get_user!(id, prefix))
    end
  end

  defp get_reassign_name(request, prefix) do
    case request.reassign_to_user_id do
      nil ->
        Map.put(request, :reassigned_user, nil)
      id ->
        Map.put(request, :reassigned_user, Staff.get_user!(id, prefix))
    end
  end

  def get_reassign_reschedule_request!(id, prefix), do: Repo.get!(ReassignRescheduleRequest, id, prefix: prefix) |> set_asset_name(prefix)

  def create_reassign_reschedule_requests(reassign_attrs, prefix, user) do
    result =
    Enum.map(reassign_attrs["work_order_ids"], fn x ->
      Map.put(reassign_attrs, "work_order_id", x) |> create_reassign_reschedule_request(prefix, user)
    end)
    error_case = Enum.map(result, fn {a, b} -> if a == :error do b end end) |> Enum.filter(fn e -> !is_nil(e) end)
    IO.inspect(error_case)
    case length(error_case) do
      0 -> {:ok, result |> Enum.map(fn {:ok, r} -> r end)}
      _ ->  {:multiple_error, error_case}
    end
  end

  def create_reassign_reschedule_request(attrs \\ %{}, prefix, user) do
    user = Staff.get_user!(user.id, prefix)
    if is_nil(user.employee.reports_to) do
      reassign_attrs = %{"requester_user_id" => user.id}
      reschedule_attrs = %{"reschedule_date" => attrs["reschedule_date"], "reschedule_time" => attrs["reschedule_time"]}
      work_order = Workorder.get_work_order!(attrs["work_order_id"], prefix)
      case attrs["request_for"] do
        "REAS" -> Workorder.update_work_order(work_order, reassign_attrs, prefix, user)
        "RESC" -> Workorder.update_work_order(work_order, reschedule_attrs, prefix, user)
      end
    else
      reports_to_user = Staff.get_user_from_employee(user.employee.reports_to, prefix)
      attrs = Map.merge(attrs, %{"requester_user_id" => user.id, "reports_to_user_id" => reports_to_user.id})
      result =
        %ReassignRescheduleRequest{}
        |> ReassignRescheduleRequest.changeset(attrs)
        |> Repo.insert(prefix: prefix)

      case result do
        {:ok, request} ->
          {:ok, preload_functions(request, prefix)}

        _ ->
          result
      end
    end
  end

  defp check_next_occurrence_for_reschedule(cs, prefix) do
    request_for = get_field(cs, :request_for, nil)
    check_request_type(request_for, cs, prefix)
  end

  defp check_request_type("RESC", cs, prefix), do: validate_next_occurrence(cs, prefix)
  defp check_request_type(_, cs, _prefix), do: cs

  defp validate_next_occurrence(cs, prefix) do
    work_order = get_work_order(get_field(cs, :work_order_id, nil), prefix)
    reschedule_date = get_field(cs, :reschedule_date, nil)
    reschedule_time = get_field(cs, :reschedule_time, nil)
    workorder_schedule =
      cond do
        !is_nil(work_order) -> get_workorder_schedule(work_order.workorder_schedule_id, prefix)
        true -> nil
      end

    cond do
      is_nil(work_order) or is_nil(workorder_schedule) ->
        cs
      is_nil(workorder_schedule.next_occurrence_date) or is_nil(workorder_schedule.next_occurrence_time) ->
        cs
      Date.compare(reschedule_date, workorder_schedule.next_occurrence_date) not in [:lt, :eq] ->
        add_error(cs, :reschedule_date, "Date exceeding next occurrence")
      Time.compare(reschedule_time, workorder_schedule.next_occurrence_time) == :lt ->
        add_error(cs, :reschedule_time, "Time exceeding next occurrence")
      true ->
        cs
    end
  end

  defp get_work_order(nil, _prefix), do: nil
  defp get_work_order(work_order_id, prefix), do: Workorder.get_work_order!(work_order_id, prefix)

  defp get_workorder_schedule(nil, _prefix), do: nil
  defp get_workorder_schedule(workorder_schedule_id, prefix), do: Workorder.get_workorder_schedule(workorder_schedule_id, prefix)


  def update_reassign_reschedule_request(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs, prefix) do
    reassign_reschedule_request
    |> ReassignRescheduleRequest.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def reassign_work_order_update(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs, prefix, user) do
    reassign_reschedule_request
    |> ReassignRescheduleRequest.update_for_reassign_changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> update_work_order(prefix, user, "REAS")
  end

  def reschedule_work_order_update(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs, prefix, user) do
    reassign_reschedule_request
    |> ReassignRescheduleRequest.update_for_reschedule_changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> update_work_order(prefix, user, "RESC")
  end

  def delete_reassign_reschedule_request(%ReassignRescheduleRequest{} = reassign_reschedule_request, prefix) do
    Repo.delete(reassign_reschedule_request, prefix: prefix)
  end

  def change_reassign_reschedule_request(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs \\ %{}) do
    ReassignRescheduleRequest.changeset(reassign_reschedule_request, attrs)
  end

  defp add_reports_to(cs, prefix) do
    user = get_field(cs, :requester_user_id, nil) |> get_user_from_changeset(prefix)
    employee = Staff.get_employee_from_user(user.employee_id, prefix)
    cond do
      !is_nil(user) and !is_nil(employee) and !is_nil(employee.reports_to) ->
        # reports_to_user = Staff.get_user_from_employee(employee.id, prefix)
        change(cs, %{reports_to_user_id: employee.reports_to})
      true ->
        cs
    end
  end

  defp update_work_order({:error, changeset}, _prefix, _user, _type), do: {:error, changeset}

  defp update_work_order({:ok, request}, prefix, user, type) do
    if request.status == "AP" do
      work_order = Workorder.get_work_order!(request.work_order_id, prefix)
      Workorder.reassign_reschedule_work_order(work_order, get_attrs_on_type(type, request), prefix, user)
      {:ok, request |> preload_functions(prefix)}
    else
      {:ok, request |> preload_functions(prefix)}
    end
  end

  def preload_functions(request, prefix) do
    set_asset_name(request, prefix)
    |> get_requester_name(prefix)
    |> get_reports_name(prefix)
    |> get_reassign_name(prefix)
  end

  defp get_user_from_changeset(nil, _prefix), do: nil
  defp get_user_from_changeset(user_id, prefix), do: Staff.get_user(user_id, prefix)

  defp get_attrs_on_type("REAS", request), do: %{"user_id" => request.reassign_to_user_id}
  defp get_attrs_on_type("RESC", request), do: %{"scheduled_date" => request.reschedule_date, "scheduled_time" => request.reschedule_time}
end

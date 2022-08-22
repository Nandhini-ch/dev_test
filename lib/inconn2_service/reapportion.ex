defmodule Inconn2Service.Reapportion do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo

  alias Inconn2Service.Staff
  alias Inconn2Service.Workorder
  alias Inconn2Service.Reapportion.ReassignRescheduleRequest

  @spec list_reassign_reschedule_requests(any) :: any
  def list_reassign_reschedule_requests(prefix) do
    Repo.all(ReassignRescheduleRequest, prefix: prefix)
  end

  def list_reassign_reschedule_requests_to_be_approved(prefix, user) do
    from(rrr in ReassignRescheduleRequest, where: rrr.reports_to_user_id == ^user.id and rrr.status != "AP")
    |> Repo.all(prefix: prefix)
  end

  def list_reassign_reschedule_requests_pending(prefix, user) do
    from(rrr in ReassignRescheduleRequest, where: rrr.requester_user_id == ^user.id)
    |> Repo.all(prefix: prefix)
  end

  def get_reassign_reschedule_request!(id, prefix), do: Repo.get!(ReassignRescheduleRequest, id, prefix: prefix)


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
    %ReassignRescheduleRequest{}
    |> ReassignRescheduleRequest.changeset(Map.put(attrs, "requester_user_id", user.id))
    |> add_reports_to(prefix)
    |> Repo.insert(prefix: prefix)
  end

  def update_reassign_reschedule_request(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs, prefix) do
    reassign_reschedule_request
    |> ReassignRescheduleRequest.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def reassign_work_order_update(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs, prefix, user) do
    reassign_reschedule_request
    |> ReassignRescheduleRequest.update_for_reassign_changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> update_work_order(prefix, user)
  end

  defp update_work_order({:error, changeset}, _prefix, _user), do: {:error, changeset}

  defp update_work_order({:ok, request}, prefix, user) do
    work_order = Workorder.get_work_order!(request.work_order_id, prefix)
    Workorder.reassign_work_order(work_order, %{"user_id" => request.reassign_to_user_id}, prefix, user)
    {:ok, request}
  end

  def delete_reassign_reschedule_request(%ReassignRescheduleRequest{} = reassign_reschedule_request, prefix) do
    Repo.delete(reassign_reschedule_request, prefix: prefix)
  end

  def change_reassign_reschedule_request(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs \\ %{}) do
    ReassignRescheduleRequest.changeset(reassign_reschedule_request, attrs)
  end

  defp add_reports_to(cs, prefix) do
    user = get_field(cs, :requester_user_id, nil) |> get_user_from_changeset(prefix)
    employee = Staff.get_employee_of_user(user, prefix)
    cond do
      !is_nil(user) and !is_nil(employee) and !is_nil(employee.reports_to) ->
        reports_to_user = Staff.get_user_from_employee(employee.id, prefix)
        change(cs, %{reports_to_user_id: reports_to_user.id})
      !is_nil(user) and !is_nil(employee) ->
        add_error(cs, :reports_to_user_id, "The employee has no reports to")
      !is_nil(user) ->
        add_error(cs, :reports_to_user_id, "The User is not registered as an employee")
      true ->
        cs
    end
  end

  defp get_user_from_changeset(nil, _prefix), do: nil
  defp get_user_from_changeset(user_id, prefix), do: Staff.get_user(user_id, prefix)
end

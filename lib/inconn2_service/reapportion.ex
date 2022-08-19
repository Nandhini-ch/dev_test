defmodule Inconn2Service.Reapportion do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo

  alias Inconn2Service.Staff
  alias Inconn2Service.Reapportion.ReassignRescheduleRequest

  @spec list_reassign_reschedule_requests(any) :: any
  def list_reassign_reschedule_requests(prefix) do
    Repo.all(ReassignRescheduleRequest, prefix: prefix)
  end

  def get_reassign_reschedule_request!(id, prefix), do: Repo.get!(ReassignRescheduleRequest, id, prefix: prefix)


  def create_reassign_reschedule_requests(reassign_attrs, prefix) do
    Enum.map(reassign_attrs["work_order_ids"], fn x ->
      Map.put(reassign_attrs, "work_order_id", x) |> create_reassign_reschedule_request(prefix)
    end)
  end

  def create_reassign_reschedule_request(attrs \\ %{}, prefix) do
    %ReassignRescheduleRequest{}
    |> ReassignRescheduleRequest.changeset(attrs)
    |> add_reports_to(prefix)
    |> Repo.insert(prefix: prefix)
  end

  def update_reassign_reschedule_request(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs, prefix) do
    reassign_reschedule_request
    |> ReassignRescheduleRequest.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def respond_to_reassign_work_order(%ReassignRescheduleRequest{} = reassign_reschedule_request, attrs, prefix) do
    reassign_reschedule_request
    |> ReassignRescheduleRequest.update_for_reassign_changeset(attrs)
    |> Repo.update(prefix: prefix)
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
        change(cs, %{reports_to_user_id: employee.user_id})
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

defmodule Inconn2Service.ReapportionTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Reapportion

  describe "reassign_reschedule_requests" do
    alias Inconn2Service.Reapportion.ReassignRescheduleRequest

    @valid_attrs %{reassign_to_user_id: 42, reports_to_user_id: 42, requested_user_id: 42, reschedule_date: ~D[2010-04-17], reschedule_time: ~T[14:00:00]}
    @update_attrs %{reassign_to_user_id: 43, reports_to_user_id: 43, requested_user_id: 43, reschedule_date: ~D[2011-05-18], reschedule_time: ~T[15:01:01]}
    @invalid_attrs %{reassign_to_user_id: nil, reports_to_user_id: nil, requested_user_id: nil, reschedule_date: nil, reschedule_time: nil}

    def reassign_reschedule_request_fixture(attrs \\ %{}) do
      {:ok, reassign_reschedule_request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Reapportion.create_reassign_reschedule_request()

      reassign_reschedule_request
    end

    test "list_reassign_reschedule_requests/0 returns all reassign_reschedule_requests" do
      reassign_reschedule_request = reassign_reschedule_request_fixture()
      assert Reapportion.list_reassign_reschedule_requests() == [reassign_reschedule_request]
    end

    test "get_reassign_reschedule_request!/1 returns the reassign_reschedule_request with given id" do
      reassign_reschedule_request = reassign_reschedule_request_fixture()
      assert Reapportion.get_reassign_reschedule_request!(reassign_reschedule_request.id) == reassign_reschedule_request
    end

    test "create_reassign_reschedule_request/1 with valid data creates a reassign_reschedule_request" do
      assert {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} = Reapportion.create_reassign_reschedule_request(@valid_attrs)
      assert reassign_reschedule_request.reassign_to_user_id == 42
      assert reassign_reschedule_request.reports_to_user_id == 42
      assert reassign_reschedule_request.requested_user_id == 42
      assert reassign_reschedule_request.reschedule_date == ~D[2010-04-17]
      assert reassign_reschedule_request.reschedule_time == ~T[14:00:00]
    end

    test "create_reassign_reschedule_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reapportion.create_reassign_reschedule_request(@invalid_attrs)
    end

    test "update_reassign_reschedule_request/2 with valid data updates the reassign_reschedule_request" do
      reassign_reschedule_request = reassign_reschedule_request_fixture()
      assert {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} = Reapportion.update_reassign_reschedule_request(reassign_reschedule_request, @update_attrs)
      assert reassign_reschedule_request.reassign_to_user_id == 43
      assert reassign_reschedule_request.reports_to_user_id == 43
      assert reassign_reschedule_request.requested_user_id == 43
      assert reassign_reschedule_request.reschedule_date == ~D[2011-05-18]
      assert reassign_reschedule_request.reschedule_time == ~T[15:01:01]
    end

    test "update_reassign_reschedule_request/2 with invalid data returns error changeset" do
      reassign_reschedule_request = reassign_reschedule_request_fixture()
      assert {:error, %Ecto.Changeset{}} = Reapportion.update_reassign_reschedule_request(reassign_reschedule_request, @invalid_attrs)
      assert reassign_reschedule_request == Reapportion.get_reassign_reschedule_request!(reassign_reschedule_request.id)
    end

    test "delete_reassign_reschedule_request/1 deletes the reassign_reschedule_request" do
      reassign_reschedule_request = reassign_reschedule_request_fixture()
      assert {:ok, %ReassignRescheduleRequest{}} = Reapportion.delete_reassign_reschedule_request(reassign_reschedule_request)
      assert_raise Ecto.NoResultsError, fn -> Reapportion.get_reassign_reschedule_request!(reassign_reschedule_request.id) end
    end

    test "change_reassign_reschedule_request/1 returns a reassign_reschedule_request changeset" do
      reassign_reschedule_request = reassign_reschedule_request_fixture()
      assert %Ecto.Changeset{} = Reapportion.change_reassign_reschedule_request(reassign_reschedule_request)
    end
  end
end

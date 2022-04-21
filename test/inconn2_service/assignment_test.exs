defmodule Inconn2Service.AssignmentTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Assignment

  describe "employee_rosters" do
    alias Inconn2Service.Assignment.EmployeeRoster

    @valid_attrs %{end_date: ~D[2010-04-17], start_date: ~D[2010-04-17]}
    @update_attrs %{end_date: ~D[2011-05-18], start_date: ~D[2011-05-18]}
    @invalid_attrs %{end_date: nil, start_date: nil}

    def employee_roster_fixture(attrs \\ %{}) do
      {:ok, employee_roster} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Assignment.create_employee_roster()

      employee_roster
    end

    test "list_employee_rosters/0 returns all employee_rosters" do
      employee_roster = employee_roster_fixture()
      assert Assignment.list_employee_rosters() == [employee_roster]
    end

    test "get_employee_roster!/1 returns the employee_roster with given id" do
      employee_roster = employee_roster_fixture()
      assert Assignment.get_employee_roster!(employee_roster.id) == employee_roster
    end

    test "create_employee_roster/1 with valid data creates a employee_roster" do
      assert {:ok, %EmployeeRoster{} = employee_roster} = Assignment.create_employee_roster(@valid_attrs)
      assert employee_roster.end_date == ~D[2010-04-17]
      assert employee_roster.start_date == ~D[2010-04-17]
    end

    test "create_employee_roster/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignment.create_employee_roster(@invalid_attrs)
    end

    test "update_employee_roster/2 with valid data updates the employee_roster" do
      employee_roster = employee_roster_fixture()
      assert {:ok, %EmployeeRoster{} = employee_roster} = Assignment.update_employee_roster(employee_roster, @update_attrs)
      assert employee_roster.end_date == ~D[2011-05-18]
      assert employee_roster.start_date == ~D[2011-05-18]
    end

    test "update_employee_roster/2 with invalid data returns error changeset" do
      employee_roster = employee_roster_fixture()
      assert {:error, %Ecto.Changeset{}} = Assignment.update_employee_roster(employee_roster, @invalid_attrs)
      assert employee_roster == Assignment.get_employee_roster!(employee_roster.id)
    end

    test "delete_employee_roster/1 deletes the employee_roster" do
      employee_roster = employee_roster_fixture()
      assert {:ok, %EmployeeRoster{}} = Assignment.delete_employee_roster(employee_roster)
      assert_raise Ecto.NoResultsError, fn -> Assignment.get_employee_roster!(employee_roster.id) end
    end

    test "change_employee_roster/1 returns a employee_roster changeset" do
      employee_roster = employee_roster_fixture()
      assert %Ecto.Changeset{} = Assignment.change_employee_roster(employee_roster)
    end
  end

  describe "attendances" do
    alias Inconn2Service.Assignment.Attendance

    @valid_attrs %{attendance: [], date: ~D[2010-04-17], shift_id: 42}
    @update_attrs %{attendance: [], date: ~D[2011-05-18], shift_id: 43}
    @invalid_attrs %{attendance: nil, date: nil, shift_id: nil}

    def attendance_fixture(attrs \\ %{}) do
      {:ok, attendance} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Assignment.create_attendance()

      attendance
    end

    test "list_attendances/0 returns all attendances" do
      attendance = attendance_fixture()
      assert Assignment.list_attendances() == [attendance]
    end

    test "get_attendance!/1 returns the attendance with given id" do
      attendance = attendance_fixture()
      assert Assignment.get_attendance!(attendance.id) == attendance
    end

    test "create_attendance/1 with valid data creates a attendance" do
      assert {:ok, %Attendance{} = attendance} = Assignment.create_attendance(@valid_attrs)
      assert attendance.attendance == []
      assert attendance.date == ~D[2010-04-17]
      assert attendance.shift_id == 42
    end

    test "create_attendance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignment.create_attendance(@invalid_attrs)
    end

    test "update_attendance/2 with valid data updates the attendance" do
      attendance = attendance_fixture()
      assert {:ok, %Attendance{} = attendance} = Assignment.update_attendance(attendance, @update_attrs)
      assert attendance.attendance == []
      assert attendance.date == ~D[2011-05-18]
      assert attendance.shift_id == 43
    end

    test "update_attendance/2 with invalid data returns error changeset" do
      attendance = attendance_fixture()
      assert {:error, %Ecto.Changeset{}} = Assignment.update_attendance(attendance, @invalid_attrs)
      assert attendance == Assignment.get_attendance!(attendance.id)
    end

    test "delete_attendance/1 deletes the attendance" do
      attendance = attendance_fixture()
      assert {:ok, %Attendance{}} = Assignment.delete_attendance(attendance)
      assert_raise Ecto.NoResultsError, fn -> Assignment.get_attendance!(attendance.id) end
    end

    test "change_attendance/1 returns a attendance changeset" do
      attendance = attendance_fixture()
      assert %Ecto.Changeset{} = Assignment.change_attendance(attendance)
    end
  end

  describe "attendance_references" do
    alias Inconn2Service.Assignment.AttendanceReference

    @valid_attrs %{employee_id: 42, reference_image: "some reference_image", status: "some status"}
    @update_attrs %{employee_id: 43, reference_image: "some updated reference_image", status: "some updated status"}
    @invalid_attrs %{employee_id: nil, reference_image: nil, status: nil}

    def attendance_reference_fixture(attrs \\ %{}) do
      {:ok, attendance_reference} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Assignment.create_attendance_reference()

      attendance_reference
    end

    test "list_attendance_references/0 returns all attendance_references" do
      attendance_reference = attendance_reference_fixture()
      assert Assignment.list_attendance_references() == [attendance_reference]
    end

    test "get_attendance_reference!/1 returns the attendance_reference with given id" do
      attendance_reference = attendance_reference_fixture()
      assert Assignment.get_attendance_reference!(attendance_reference.id) == attendance_reference
    end

    test "create_attendance_reference/1 with valid data creates a attendance_reference" do
      assert {:ok, %AttendanceReference{} = attendance_reference} = Assignment.create_attendance_reference(@valid_attrs)
      assert attendance_reference.employee_id == 42
      assert attendance_reference.reference_image == "some reference_image"
      assert attendance_reference.status == "some status"
    end

    test "create_attendance_reference/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignment.create_attendance_reference(@invalid_attrs)
    end

    test "update_attendance_reference/2 with valid data updates the attendance_reference" do
      attendance_reference = attendance_reference_fixture()
      assert {:ok, %AttendanceReference{} = attendance_reference} = Assignment.update_attendance_reference(attendance_reference, @update_attrs)
      assert attendance_reference.employee_id == 43
      assert attendance_reference.reference_image == "some updated reference_image"
      assert attendance_reference.status == "some updated status"
    end

    test "update_attendance_reference/2 with invalid data returns error changeset" do
      attendance_reference = attendance_reference_fixture()
      assert {:error, %Ecto.Changeset{}} = Assignment.update_attendance_reference(attendance_reference, @invalid_attrs)
      assert attendance_reference == Assignment.get_attendance_reference!(attendance_reference.id)
    end

    test "delete_attendance_reference/1 deletes the attendance_reference" do
      attendance_reference = attendance_reference_fixture()
      assert {:ok, %AttendanceReference{}} = Assignment.delete_attendance_reference(attendance_reference)
      assert_raise Ecto.NoResultsError, fn -> Assignment.get_attendance_reference!(attendance_reference.id) end
    end

    test "change_attendance_reference/1 returns a attendance_reference changeset" do
      attendance_reference = attendance_reference_fixture()
      assert %Ecto.Changeset{} = Assignment.change_attendance_reference(attendance_reference)
    end
  end

  describe "attendance_failure_logs" do
    alias Inconn2Service.Assignment.AttendanceFailureLog

    @valid_attrs %{date_time: ~N[2010-04-17 14:00:00], employee_id: 42, failure_image: "some failure_image"}
    @update_attrs %{date_time: ~N[2011-05-18 15:01:01], employee_id: 43, failure_image: "some updated failure_image"}
    @invalid_attrs %{date_time: nil, employee_id: nil, failure_image: nil}

    def attendance_failure_log_fixture(attrs \\ %{}) do
      {:ok, attendance_failure_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Assignment.create_attendance_failure_log()

      attendance_failure_log
    end

    test "list_attendance_failure_logs/0 returns all attendance_failure_logs" do
      attendance_failure_log = attendance_failure_log_fixture()
      assert Assignment.list_attendance_failure_logs() == [attendance_failure_log]
    end

    test "get_attendance_failure_log!/1 returns the attendance_failure_log with given id" do
      attendance_failure_log = attendance_failure_log_fixture()
      assert Assignment.get_attendance_failure_log!(attendance_failure_log.id) == attendance_failure_log
    end

    test "create_attendance_failure_log/1 with valid data creates a attendance_failure_log" do
      assert {:ok, %AttendanceFailureLog{} = attendance_failure_log} = Assignment.create_attendance_failure_log(@valid_attrs)
      assert attendance_failure_log.date_time == ~N[2010-04-17 14:00:00]
      assert attendance_failure_log.employee_id == 42
      assert attendance_failure_log.failure_image == "some failure_image"
    end

    test "create_attendance_failure_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignment.create_attendance_failure_log(@invalid_attrs)
    end

    test "update_attendance_failure_log/2 with valid data updates the attendance_failure_log" do
      attendance_failure_log = attendance_failure_log_fixture()
      assert {:ok, %AttendanceFailureLog{} = attendance_failure_log} = Assignment.update_attendance_failure_log(attendance_failure_log, @update_attrs)
      assert attendance_failure_log.date_time == ~N[2011-05-18 15:01:01]
      assert attendance_failure_log.employee_id == 43
      assert attendance_failure_log.failure_image == "some updated failure_image"
    end

    test "update_attendance_failure_log/2 with invalid data returns error changeset" do
      attendance_failure_log = attendance_failure_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Assignment.update_attendance_failure_log(attendance_failure_log, @invalid_attrs)
      assert attendance_failure_log == Assignment.get_attendance_failure_log!(attendance_failure_log.id)
    end

    test "delete_attendance_failure_log/1 deletes the attendance_failure_log" do
      attendance_failure_log = attendance_failure_log_fixture()
      assert {:ok, %AttendanceFailureLog{}} = Assignment.delete_attendance_failure_log(attendance_failure_log)
      assert_raise Ecto.NoResultsError, fn -> Assignment.get_attendance_failure_log!(attendance_failure_log.id) end
    end

    test "change_attendance_failure_log/1 returns a attendance_failure_log changeset" do
      attendance_failure_log = attendance_failure_log_fixture()
      assert %Ecto.Changeset{} = Assignment.change_attendance_failure_log(attendance_failure_log)
    end
  end
end

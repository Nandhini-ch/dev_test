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
end

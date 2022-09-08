defmodule Inconn2Service.AssignmentsTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Assignments

  describe "master_rosters" do
    alias Inconn2Service.Assignments.MasterRoster

    @valid_attrs %{active: true}
    @update_attrs %{active: false}
    @invalid_attrs %{active: nil}

    def master_roster_fixture(attrs \\ %{}) do
      {:ok, master_roster} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Assignments.create_master_roster()

      master_roster
    end

    test "list_master_rosters/0 returns all master_rosters" do
      master_roster = master_roster_fixture()
      assert Assignments.list_master_rosters() == [master_roster]
    end

    test "get_master_roster!/1 returns the master_roster with given id" do
      master_roster = master_roster_fixture()
      assert Assignments.get_master_roster!(master_roster.id) == master_roster
    end

    test "create_master_roster/1 with valid data creates a master_roster" do
      assert {:ok, %MasterRoster{} = master_roster} = Assignments.create_master_roster(@valid_attrs)
      assert master_roster.active == true
    end

    test "create_master_roster/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignments.create_master_roster(@invalid_attrs)
    end

    test "update_master_roster/2 with valid data updates the master_roster" do
      master_roster = master_roster_fixture()
      assert {:ok, %MasterRoster{} = master_roster} = Assignments.update_master_roster(master_roster, @update_attrs)
      assert master_roster.active == false
    end

    test "update_master_roster/2 with invalid data returns error changeset" do
      master_roster = master_roster_fixture()
      assert {:error, %Ecto.Changeset{}} = Assignments.update_master_roster(master_roster, @invalid_attrs)
      assert master_roster == Assignments.get_master_roster!(master_roster.id)
    end

    test "delete_master_roster/1 deletes the master_roster" do
      master_roster = master_roster_fixture()
      assert {:ok, %MasterRoster{}} = Assignments.delete_master_roster(master_roster)
      assert_raise Ecto.NoResultsError, fn -> Assignments.get_master_roster!(master_roster.id) end
    end

    test "change_master_roster/1 returns a master_roster changeset" do
      master_roster = master_roster_fixture()
      assert %Ecto.Changeset{} = Assignments.change_master_roster(master_roster)
    end
  end

  describe "rosters" do
    alias Inconn2Service.Assignments.Roster

    @valid_attrs %{active: true, date: ~D[2010-04-17], employee_id: 42, shift_id: 42}
    @update_attrs %{active: false, date: ~D[2011-05-18], employee_id: 43, shift_id: 43}
    @invalid_attrs %{active: nil, date: nil, employee_id: nil, shift_id: nil}

    def roster_fixture(attrs \\ %{}) do
      {:ok, roster} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Assignments.create_roster()

      roster
    end

    test "list_rosters/0 returns all rosters" do
      roster = roster_fixture()
      assert Assignments.list_rosters() == [roster]
    end

    test "get_roster!/1 returns the roster with given id" do
      roster = roster_fixture()
      assert Assignments.get_roster!(roster.id) == roster
    end

    test "create_roster/1 with valid data creates a roster" do
      assert {:ok, %Roster{} = roster} = Assignments.create_roster(@valid_attrs)
      assert roster.active == true
      assert roster.date == ~D[2010-04-17]
      assert roster.employee_id == 42
      assert roster.shift_id == 42
    end

    test "create_roster/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assignments.create_roster(@invalid_attrs)
    end

    test "update_roster/2 with valid data updates the roster" do
      roster = roster_fixture()
      assert {:ok, %Roster{} = roster} = Assignments.update_roster(roster, @update_attrs)
      assert roster.active == false
      assert roster.date == ~D[2011-05-18]
      assert roster.employee_id == 43
      assert roster.shift_id == 43
    end

    test "update_roster/2 with invalid data returns error changeset" do
      roster = roster_fixture()
      assert {:error, %Ecto.Changeset{}} = Assignments.update_roster(roster, @invalid_attrs)
      assert roster == Assignments.get_roster!(roster.id)
    end

    test "delete_roster/1 deletes the roster" do
      roster = roster_fixture()
      assert {:ok, %Roster{}} = Assignments.delete_roster(roster)
      assert_raise Ecto.NoResultsError, fn -> Assignments.get_roster!(roster.id) end
    end

    test "change_roster/1 returns a roster changeset" do
      roster = roster_fixture()
      assert %Ecto.Changeset{} = Assignments.change_roster(roster)
    end
  end
end

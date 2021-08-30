defmodule Inconn2Service.StaffTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Staff

  describe "org_units" do
    alias Inconn2Service.Staff.OrgUnit

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def org_unit_fixture(attrs \\ %{}) do
      {:ok, org_unit} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_org_unit()

      org_unit
    end

    test "list_org_units/0 returns all org_units" do
      org_unit = org_unit_fixture()
      assert Staff.list_org_units() == [org_unit]
    end

    test "get_org_unit!/1 returns the org_unit with given id" do
      org_unit = org_unit_fixture()
      assert Staff.get_org_unit!(org_unit.id) == org_unit
    end

    test "create_org_unit/1 with valid data creates a org_unit" do
      assert {:ok, %OrgUnit{} = org_unit} = Staff.create_org_unit(@valid_attrs)
      assert org_unit.name == "some name"
    end

    test "create_org_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_org_unit(@invalid_attrs)
    end

    test "update_org_unit/2 with valid data updates the org_unit" do
      org_unit = org_unit_fixture()
      assert {:ok, %OrgUnit{} = org_unit} = Staff.update_org_unit(org_unit, @update_attrs)
      assert org_unit.name == "some updated name"
    end

    test "update_org_unit/2 with invalid data returns error changeset" do
      org_unit = org_unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_org_unit(org_unit, @invalid_attrs)
      assert org_unit == Staff.get_org_unit!(org_unit.id)
    end

    test "delete_org_unit/1 deletes the org_unit" do
      org_unit = org_unit_fixture()
      assert {:ok, %OrgUnit{}} = Staff.delete_org_unit(org_unit)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_org_unit!(org_unit.id) end
    end

    test "change_org_unit/1 returns a org_unit changeset" do
      org_unit = org_unit_fixture()
      assert %Ecto.Changeset{} = Staff.change_org_unit(org_unit)
    end
  end
end

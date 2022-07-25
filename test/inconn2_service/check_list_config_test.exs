defmodule Inconn2Service.CheckListConfigTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.CheckListConfig

  describe "checks" do
    alias Inconn2Service.CheckListConfig.Check

    @valid_attrs %{label: "some label", type: "some type"}
    @update_attrs %{label: "some updated label", type: "some updated type"}
    @invalid_attrs %{label: nil, type: nil}

    def check_fixture(attrs \\ %{}) do
      {:ok, check} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CheckListConfig.create_check()

      check
    end

    test "list_checks/0 returns all checks" do
      check = check_fixture()
      assert CheckListConfig.list_checks() == [check]
    end

    test "get_check!/1 returns the check with given id" do
      check = check_fixture()
      assert CheckListConfig.get_check!(check.id) == check
    end

    test "create_check/1 with valid data creates a check" do
      assert {:ok, %Check{} = check} = CheckListConfig.create_check(@valid_attrs)
      assert check.label == "some label"
      assert check.type == "some type"
    end

    test "create_check/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CheckListConfig.create_check(@invalid_attrs)
    end

    test "update_check/2 with valid data updates the check" do
      check = check_fixture()
      assert {:ok, %Check{} = check} = CheckListConfig.update_check(check, @update_attrs)
      assert check.label == "some updated label"
      assert check.type == "some updated type"
    end

    test "update_check/2 with invalid data returns error changeset" do
      check = check_fixture()
      assert {:error, %Ecto.Changeset{}} = CheckListConfig.update_check(check, @invalid_attrs)
      assert check == CheckListConfig.get_check!(check.id)
    end

    test "delete_check/1 deletes the check" do
      check = check_fixture()
      assert {:ok, %Check{}} = CheckListConfig.delete_check(check)
      assert_raise Ecto.NoResultsError, fn -> CheckListConfig.get_check!(check.id) end
    end

    test "change_check/1 returns a check changeset" do
      check = check_fixture()
      assert %Ecto.Changeset{} = CheckListConfig.change_check(check)
    end
  end

  describe "check_lists" do
    alias Inconn2Service.CheckListConfig.CheckList

    @valid_attrs %{check_id: [], name: "some name", type: "some type"}
    @update_attrs %{check_id: [], name: "some updated name", type: "some updated type"}
    @invalid_attrs %{check_id: nil, name: nil, type: nil}

    def check_list_fixture(attrs \\ %{}) do
      {:ok, check_list} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CheckListConfig.create_check_list()

      check_list
    end

    test "list_check_lists/0 returns all check_lists" do
      check_list = check_list_fixture()
      assert CheckListConfig.list_check_lists() == [check_list]
    end

    test "get_check_list!/1 returns the check_list with given id" do
      check_list = check_list_fixture()
      assert CheckListConfig.get_check_list!(check_list.id) == check_list
    end

    test "create_check_list/1 with valid data creates a check_list" do
      assert {:ok, %CheckList{} = check_list} = CheckListConfig.create_check_list(@valid_attrs)
      assert check_list.check_id == []
      assert check_list.name == "some name"
      assert check_list.type == "some type"
    end

    test "create_check_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CheckListConfig.create_check_list(@invalid_attrs)
    end

    test "update_check_list/2 with valid data updates the check_list" do
      check_list = check_list_fixture()
      assert {:ok, %CheckList{} = check_list} = CheckListConfig.update_check_list(check_list, @update_attrs)
      assert check_list.check_id == []
      assert check_list.name == "some updated name"
      assert check_list.type == "some updated type"
    end

    test "update_check_list/2 with invalid data returns error changeset" do
      check_list = check_list_fixture()
      assert {:error, %Ecto.Changeset{}} = CheckListConfig.update_check_list(check_list, @invalid_attrs)
      assert check_list == CheckListConfig.get_check_list!(check_list.id)
    end

    test "delete_check_list/1 deletes the check_list" do
      check_list = check_list_fixture()
      assert {:ok, %CheckList{}} = CheckListConfig.delete_check_list(check_list)
      assert_raise Ecto.NoResultsError, fn -> CheckListConfig.get_check_list!(check_list.id) end
    end

    test "change_check_list/1 returns a check_list changeset" do
      check_list = check_list_fixture()
      assert %Ecto.Changeset{} = CheckListConfig.change_check_list(check_list)
    end
  end

  describe "check_types" do
    alias Inconn2Service.CheckListConfig.CheckType

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def check_type_fixture(attrs \\ %{}) do
      {:ok, check_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CheckListConfig.create_check_type()

      check_type
    end

    test "list_check_types/0 returns all check_types" do
      check_type = check_type_fixture()
      assert CheckListConfig.list_check_types() == [check_type]
    end

    test "get_check_type!/1 returns the check_type with given id" do
      check_type = check_type_fixture()
      assert CheckListConfig.get_check_type!(check_type.id) == check_type
    end

    test "create_check_type/1 with valid data creates a check_type" do
      assert {:ok, %CheckType{} = check_type} = CheckListConfig.create_check_type(@valid_attrs)
      assert check_type.description == "some description"
      assert check_type.name == "some name"
    end

    test "create_check_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CheckListConfig.create_check_type(@invalid_attrs)
    end

    test "update_check_type/2 with valid data updates the check_type" do
      check_type = check_type_fixture()
      assert {:ok, %CheckType{} = check_type} = CheckListConfig.update_check_type(check_type, @update_attrs)
      assert check_type.description == "some updated description"
      assert check_type.name == "some updated name"
    end

    test "update_check_type/2 with invalid data returns error changeset" do
      check_type = check_type_fixture()
      assert {:error, %Ecto.Changeset{}} = CheckListConfig.update_check_type(check_type, @invalid_attrs)
      assert check_type == CheckListConfig.get_check_type!(check_type.id)
    end

    test "delete_check_type/1 deletes the check_type" do
      check_type = check_type_fixture()
      assert {:ok, %CheckType{}} = CheckListConfig.delete_check_type(check_type)
      assert_raise Ecto.NoResultsError, fn -> CheckListConfig.get_check_type!(check_type.id) end
    end

    test "change_check_type/1 returns a check_type changeset" do
      check_type = check_type_fixture()
      assert %Ecto.Changeset{} = CheckListConfig.change_check_type(check_type)
    end
  end
end

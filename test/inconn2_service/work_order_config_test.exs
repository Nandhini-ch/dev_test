defmodule Inconn2Service.WorkOrderConfigTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.WorkOrderConfig

  describe "master_task_types" do
    alias Inconn2Service.WorkOrderConfig.MasterTaskType

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def master_task_type_fixture(attrs \\ %{}) do
      {:ok, master_task_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> WorkOrderConfig.create_master_task_type()

      master_task_type
    end

    test "list_master_task_types/0 returns all master_task_types" do
      master_task_type = master_task_type_fixture()
      assert WorkOrderConfig.list_master_task_types() == [master_task_type]
    end

    test "get_master_task_type!/1 returns the master_task_type with given id" do
      master_task_type = master_task_type_fixture()
      assert WorkOrderConfig.get_master_task_type!(master_task_type.id) == master_task_type
    end

    test "create_master_task_type/1 with valid data creates a master_task_type" do
      assert {:ok, %MasterTaskType{} = master_task_type} = WorkOrderConfig.create_master_task_type(@valid_attrs)
      assert master_task_type.description == "some description"
      assert master_task_type.name == "some name"
    end

    test "create_master_task_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WorkOrderConfig.create_master_task_type(@invalid_attrs)
    end

    test "update_master_task_type/2 with valid data updates the master_task_type" do
      master_task_type = master_task_type_fixture()
      assert {:ok, %MasterTaskType{} = master_task_type} = WorkOrderConfig.update_master_task_type(master_task_type, @update_attrs)
      assert master_task_type.description == "some updated description"
      assert master_task_type.name == "some updated name"
    end

    test "update_master_task_type/2 with invalid data returns error changeset" do
      master_task_type = master_task_type_fixture()
      assert {:error, %Ecto.Changeset{}} = WorkOrderConfig.update_master_task_type(master_task_type, @invalid_attrs)
      assert master_task_type == WorkOrderConfig.get_master_task_type!(master_task_type.id)
    end

    test "delete_master_task_type/1 deletes the master_task_type" do
      master_task_type = master_task_type_fixture()
      assert {:ok, %MasterTaskType{}} = WorkOrderConfig.delete_master_task_type(master_task_type)
      assert_raise Ecto.NoResultsError, fn -> WorkOrderConfig.get_master_task_type!(master_task_type.id) end
    end

    test "change_master_task_type/1 returns a master_task_type changeset" do
      master_task_type = master_task_type_fixture()
      assert %Ecto.Changeset{} = WorkOrderConfig.change_master_task_type(master_task_type)
    end
  end

  describe "task_tasklists" do
    alias Inconn2Service.WorkOrderConfig.TaskTasklist

    @valid_attrs %{sequence: "some sequence", task_id: "some task_id", task_list_id: "some task_list_id"}
    @update_attrs %{sequence: "some updated sequence", task_id: "some updated task_id", task_list_id: "some updated task_list_id"}
    @invalid_attrs %{sequence: nil, task_id: nil, task_list_id: nil}

    def task_tasklist_fixture(attrs \\ %{}) do
      {:ok, task_tasklist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> WorkOrderConfig.create_task_tasklist()

      task_tasklist
    end

    test "list_task_tasklists/0 returns all task_tasklists" do
      task_tasklist = task_tasklist_fixture()
      assert WorkOrderConfig.list_task_tasklists() == [task_tasklist]
    end

    test "get_task_tasklist!/1 returns the task_tasklist with given id" do
      task_tasklist = task_tasklist_fixture()
      assert WorkOrderConfig.get_task_tasklist!(task_tasklist.id) == task_tasklist
    end

    test "create_task_tasklist/1 with valid data creates a task_tasklist" do
      assert {:ok, %TaskTasklist{} = task_tasklist} = WorkOrderConfig.create_task_tasklist(@valid_attrs)
      assert task_tasklist.sequence == "some sequence"
      assert task_tasklist.task_id == "some task_id"
      assert task_tasklist.task_list_id == "some task_list_id"
    end

    test "create_task_tasklist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WorkOrderConfig.create_task_tasklist(@invalid_attrs)
    end

    test "update_task_tasklist/2 with valid data updates the task_tasklist" do
      task_tasklist = task_tasklist_fixture()
      assert {:ok, %TaskTasklist{} = task_tasklist} = WorkOrderConfig.update_task_tasklist(task_tasklist, @update_attrs)
      assert task_tasklist.sequence == "some updated sequence"
      assert task_tasklist.task_id == "some updated task_id"
      assert task_tasklist.task_list_id == "some updated task_list_id"
    end

    test "update_task_tasklist/2 with invalid data returns error changeset" do
      task_tasklist = task_tasklist_fixture()
      assert {:error, %Ecto.Changeset{}} = WorkOrderConfig.update_task_tasklist(task_tasklist, @invalid_attrs)
      assert task_tasklist == WorkOrderConfig.get_task_tasklist!(task_tasklist.id)
    end

    test "delete_task_tasklist/1 deletes the task_tasklist" do
      task_tasklist = task_tasklist_fixture()
      assert {:ok, %TaskTasklist{}} = WorkOrderConfig.delete_task_tasklist(task_tasklist)
      assert_raise Ecto.NoResultsError, fn -> WorkOrderConfig.get_task_tasklist!(task_tasklist.id) end
    end

    test "change_task_tasklist/1 returns a task_tasklist changeset" do
      task_tasklist = task_tasklist_fixture()
      assert %Ecto.Changeset{} = WorkOrderConfig.change_task_tasklist(task_tasklist)
    end
  end
end

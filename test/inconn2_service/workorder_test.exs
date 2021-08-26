defmodule Inconn2Service.WorkorderTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Workorder

  describe "workorder_templates" do
    alias Inconn2Service.Workorder.WorkorderTemplate

    @valid_attrs %{applicable_end: ~D[2010-04-17], applicable_start: ~D[2010-04-17], asset_category_id: 42, create_new: "some create_new", estimated_time: 42, max_times: 42, name: "some name", repeat_every: 42, repeat_unit: "some repeat_unit", scheduled: "some scheduled", task_list_id: 42, tasks: [], time_end: ~T[14:00:00], time_start: ~T[14:00:00], workorder_prior_time: 42}
    @update_attrs %{applicable_end: ~D[2011-05-18], applicable_start: ~D[2011-05-18], asset_category_id: 43, create_new: "some updated create_new", estimated_time: 43, max_times: 43, name: "some updated name", repeat_every: 43, repeat_unit: "some updated repeat_unit", scheduled: "some updated scheduled", task_list_id: 43, tasks: [], time_end: ~T[15:01:01], time_start: ~T[15:01:01], workorder_prior_time: 43}
    @invalid_attrs %{applicable_end: nil, applicable_start: nil, asset_category_id: nil, create_new: nil, estimated_time: nil, max_times: nil, name: nil, repeat_every: nil, repeat_unit: nil, scheduled: nil, task_list_id: nil, tasks: nil, time_end: nil, time_start: nil, workorder_prior_time: nil}

    def workorder_template_fixture(attrs \\ %{}) do
      {:ok, workorder_template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workorder.create_workorder_template()

      workorder_template
    end

    test "list_workorder_templates/0 returns all workorder_templates" do
      workorder_template = workorder_template_fixture()
      assert Workorder.list_workorder_templates() == [workorder_template]
    end

    test "get_workorder_template!/1 returns the workorder_template with given id" do
      workorder_template = workorder_template_fixture()
      assert Workorder.get_workorder_template!(workorder_template.id) == workorder_template
    end

    test "create_workorder_template/1 with valid data creates a workorder_template" do
      assert {:ok, %WorkorderTemplate{} = workorder_template} = Workorder.create_workorder_template(@valid_attrs)
      assert workorder_template.applicable_end == ~D[2010-04-17]
      assert workorder_template.applicable_start == ~D[2010-04-17]
      assert workorder_template.asset_category_id == 42
      assert workorder_template.create_new == "some create_new"
      assert workorder_template.estimated_time == 42
      assert workorder_template.max_times == 42
      assert workorder_template.name == "some name"
      assert workorder_template.repeat_every == 42
      assert workorder_template.repeat_unit == "some repeat_unit"
      assert workorder_template.scheduled == "some scheduled"
      assert workorder_template.task_list_id == 42
      assert workorder_template.tasks == []
      assert workorder_template.time_end == ~T[14:00:00]
      assert workorder_template.time_start == ~T[14:00:00]
      assert workorder_template.workorder_prior_time == 42
    end

    test "create_workorder_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workorder.create_workorder_template(@invalid_attrs)
    end

    test "update_workorder_template/2 with valid data updates the workorder_template" do
      workorder_template = workorder_template_fixture()
      assert {:ok, %WorkorderTemplate{} = workorder_template} = Workorder.update_workorder_template(workorder_template, @update_attrs)
      assert workorder_template.applicable_end == ~D[2011-05-18]
      assert workorder_template.applicable_start == ~D[2011-05-18]
      assert workorder_template.asset_category_id == 43
      assert workorder_template.create_new == "some updated create_new"
      assert workorder_template.estimated_time == 43
      assert workorder_template.max_times == 43
      assert workorder_template.name == "some updated name"
      assert workorder_template.repeat_every == 43
      assert workorder_template.repeat_unit == "some updated repeat_unit"
      assert workorder_template.scheduled == "some updated scheduled"
      assert workorder_template.task_list_id == 43
      assert workorder_template.tasks == []
      assert workorder_template.time_end == ~T[15:01:01]
      assert workorder_template.time_start == ~T[15:01:01]
      assert workorder_template.workorder_prior_time == 43
    end

    test "update_workorder_template/2 with invalid data returns error changeset" do
      workorder_template = workorder_template_fixture()
      assert {:error, %Ecto.Changeset{}} = Workorder.update_workorder_template(workorder_template, @invalid_attrs)
      assert workorder_template == Workorder.get_workorder_template!(workorder_template.id)
    end

    test "delete_workorder_template/1 deletes the workorder_template" do
      workorder_template = workorder_template_fixture()
      assert {:ok, %WorkorderTemplate{}} = Workorder.delete_workorder_template(workorder_template)
      assert_raise Ecto.NoResultsError, fn -> Workorder.get_workorder_template!(workorder_template.id) end
    end

    test "change_workorder_template/1 returns a workorder_template changeset" do
      workorder_template = workorder_template_fixture()
      assert %Ecto.Changeset{} = Workorder.change_workorder_template(workorder_template)
    end
  end
end

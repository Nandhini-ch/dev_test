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

  describe "workorder_schedules" do
    alias Inconn2Service.Workorder.WorkorderSchedule

    @valid_attrs %{config: "some config"}
    @update_attrs %{config: "some updated config"}
    @invalid_attrs %{config: nil}

    def workorder_schedule_fixture(attrs \\ %{}) do
      {:ok, workorder_schedule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workorder.create_workorder_schedule()

      workorder_schedule
    end

    test "list_workorder_schedules/0 returns all workorder_schedules" do
      workorder_schedule = workorder_schedule_fixture()
      assert Workorder.list_workorder_schedules() == [workorder_schedule]
    end

    test "get_workorder_schedule!/1 returns the workorder_schedule with given id" do
      workorder_schedule = workorder_schedule_fixture()
      assert Workorder.get_workorder_schedule!(workorder_schedule.id) == workorder_schedule
    end

    test "create_workorder_schedule/1 with valid data creates a workorder_schedule" do
      assert {:ok, %WorkorderSchedule{} = workorder_schedule} = Workorder.create_workorder_schedule(@valid_attrs)
      assert workorder_schedule.config == "some config"
    end

    test "create_workorder_schedule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workorder.create_workorder_schedule(@invalid_attrs)
    end

    test "update_workorder_schedule/2 with valid data updates the workorder_schedule" do
      workorder_schedule = workorder_schedule_fixture()
      assert {:ok, %WorkorderSchedule{} = workorder_schedule} = Workorder.update_workorder_schedule(workorder_schedule, @update_attrs)
      assert workorder_schedule.config == "some updated config"
    end

    test "update_workorder_schedule/2 with invalid data returns error changeset" do
      workorder_schedule = workorder_schedule_fixture()
      assert {:error, %Ecto.Changeset{}} = Workorder.update_workorder_schedule(workorder_schedule, @invalid_attrs)
      assert workorder_schedule == Workorder.get_workorder_schedule!(workorder_schedule.id)
    end

    test "delete_workorder_schedule/1 deletes the workorder_schedule" do
      workorder_schedule = workorder_schedule_fixture()
      assert {:ok, %WorkorderSchedule{}} = Workorder.delete_workorder_schedule(workorder_schedule)
      assert_raise Ecto.NoResultsError, fn -> Workorder.get_workorder_schedule!(workorder_schedule.id) end
    end

    test "change_workorder_schedule/1 returns a workorder_schedule changeset" do
      workorder_schedule = workorder_schedule_fixture()
      assert %Ecto.Changeset{} = Workorder.change_workorder_schedule(workorder_schedule)
    end
  end

  describe "work_orders" do
    alias Inconn2Service.Workorder.WorkOrder

    @valid_attrs %{asset_id: 42, site_id: 42, type: "some type"}
    @update_attrs %{asset_id: 43, site_id: 43, type: "some updated type"}
    @invalid_attrs %{asset_id: nil, site_id: nil, type: nil}

    def work_order_fixture(attrs \\ %{}) do
      {:ok, work_order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workorder.create_work_order()

      work_order
    end

    test "list_work_orders/0 returns all work_orders" do
      work_order = work_order_fixture()
      assert Workorder.list_work_orders() == [work_order]
    end

    test "get_work_order!/1 returns the work_order with given id" do
      work_order = work_order_fixture()
      assert Workorder.get_work_order!(work_order.id) == work_order
    end

    test "create_work_order/1 with valid data creates a work_order" do
      assert {:ok, %WorkOrder{} = work_order} = Workorder.create_work_order(@valid_attrs)
      assert work_order.asset_id == 42
      assert work_order.site_id == 42
      assert work_order.type == "some type"
    end

    test "create_work_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workorder.create_work_order(@invalid_attrs)
    end

    test "update_work_order/2 with valid data updates the work_order" do
      work_order = work_order_fixture()
      assert {:ok, %WorkOrder{} = work_order} = Workorder.update_work_order(work_order, @update_attrs)
      assert work_order.asset_id == 43
      assert work_order.site_id == 43
      assert work_order.type == "some updated type"
    end

    test "update_work_order/2 with invalid data returns error changeset" do
      work_order = work_order_fixture()
      assert {:error, %Ecto.Changeset{}} = Workorder.update_work_order(work_order, @invalid_attrs)
      assert work_order == Workorder.get_work_order!(work_order.id)
    end

    test "delete_work_order/1 deletes the work_order" do
      work_order = work_order_fixture()
      assert {:ok, %WorkOrder{}} = Workorder.delete_work_order(work_order)
      assert_raise Ecto.NoResultsError, fn -> Workorder.get_work_order!(work_order.id) end
    end

    test "change_work_order/1 returns a work_order changeset" do
      work_order = work_order_fixture()
      assert %Ecto.Changeset{} = Workorder.change_work_order(work_order)
    end
  end

  describe "workorder_tasks" do
    alias Inconn2Service.Workorder.WorkorderTask

    @valid_attrs %{sequence: 42, task_id: 42}
    @update_attrs %{sequence: 43, task_id: 43}
    @invalid_attrs %{sequence: nil, task_id: nil}

    def workorder_task_fixture(attrs \\ %{}) do
      {:ok, workorder_task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workorder.create_workorder_task()

      workorder_task
    end

    test "list_workorder_tasks/0 returns all workorder_tasks" do
      workorder_task = workorder_task_fixture()
      assert Workorder.list_workorder_tasks() == [workorder_task]
    end

    test "get_workorder_task!/1 returns the workorder_task with given id" do
      workorder_task = workorder_task_fixture()
      assert Workorder.get_workorder_task!(workorder_task.id) == workorder_task
    end

    test "create_workorder_task/1 with valid data creates a workorder_task" do
      assert {:ok, %WorkorderTask{} = workorder_task} = Workorder.create_workorder_task(@valid_attrs)
      assert workorder_task.sequence == 42
      assert workorder_task.task_id == 42
    end

    test "create_workorder_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workorder.create_workorder_task(@invalid_attrs)
    end

    test "update_workorder_task/2 with valid data updates the workorder_task" do
      workorder_task = workorder_task_fixture()
      assert {:ok, %WorkorderTask{} = workorder_task} = Workorder.update_workorder_task(workorder_task, @update_attrs)
      assert workorder_task.sequence == 43
      assert workorder_task.task_id == 43
    end

    test "update_workorder_task/2 with invalid data returns error changeset" do
      workorder_task = workorder_task_fixture()
      assert {:error, %Ecto.Changeset{}} = Workorder.update_workorder_task(workorder_task, @invalid_attrs)
      assert workorder_task == Workorder.get_workorder_task!(workorder_task.id)
    end

    test "delete_workorder_task/1 deletes the workorder_task" do
      workorder_task = workorder_task_fixture()
      assert {:ok, %WorkorderTask{}} = Workorder.delete_workorder_task(workorder_task)
      assert_raise Ecto.NoResultsError, fn -> Workorder.get_workorder_task!(workorder_task.id) end
    end

    test "change_workorder_task/1 returns a workorder_task changeset" do
      workorder_task = workorder_task_fixture()
      assert %Ecto.Changeset{} = Workorder.change_workorder_task(workorder_task)
    end
  end

  describe "workorder_status_tracks" do
    alias Inconn2Service.Workorder.WorkorderStatusTrack

    @valid_attrs %{status: "some status", work_order_id: 42}
    @update_attrs %{status: "some updated status", work_order_id: 43}
    @invalid_attrs %{status: nil, work_order_id: nil}

    def workorder_status_track_fixture(attrs \\ %{}) do
      {:ok, workorder_status_track} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workorder.create_workorder_status_track()

      workorder_status_track
    end

    test "list_workorder_status_tracks/0 returns all workorder_status_tracks" do
      workorder_status_track = workorder_status_track_fixture()
      assert Workorder.list_workorder_status_tracks() == [workorder_status_track]
    end

    test "get_workorder_status_track!/1 returns the workorder_status_track with given id" do
      workorder_status_track = workorder_status_track_fixture()
      assert Workorder.get_workorder_status_track!(workorder_status_track.id) == workorder_status_track
    end

    test "create_workorder_status_track/1 with valid data creates a workorder_status_track" do
      assert {:ok, %WorkorderStatusTrack{} = workorder_status_track} = Workorder.create_workorder_status_track(@valid_attrs)
      assert workorder_status_track.status == "some status"
      assert workorder_status_track.work_order_id == 42
    end

    test "create_workorder_status_track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workorder.create_workorder_status_track(@invalid_attrs)
    end

    test "update_workorder_status_track/2 with valid data updates the workorder_status_track" do
      workorder_status_track = workorder_status_track_fixture()
      assert {:ok, %WorkorderStatusTrack{} = workorder_status_track} = Workorder.update_workorder_status_track(workorder_status_track, @update_attrs)
      assert workorder_status_track.status == "some updated status"
      assert workorder_status_track.work_order_id == 43
    end

    test "update_workorder_status_track/2 with invalid data returns error changeset" do
      workorder_status_track = workorder_status_track_fixture()
      assert {:error, %Ecto.Changeset{}} = Workorder.update_workorder_status_track(workorder_status_track, @invalid_attrs)
      assert workorder_status_track == Workorder.get_workorder_status_track!(workorder_status_track.id)
    end

    test "delete_workorder_status_track/1 deletes the workorder_status_track" do
      workorder_status_track = workorder_status_track_fixture()
      assert {:ok, %WorkorderStatusTrack{}} = Workorder.delete_workorder_status_track(workorder_status_track)
      assert_raise Ecto.NoResultsError, fn -> Workorder.get_workorder_status_track!(workorder_status_track.id) end
    end

    test "change_workorder_status_track/1 returns a workorder_status_track changeset" do
      workorder_status_track = workorder_status_track_fixture()
      assert %Ecto.Changeset{} = Workorder.change_workorder_status_track(workorder_status_track)
    end
  end
end

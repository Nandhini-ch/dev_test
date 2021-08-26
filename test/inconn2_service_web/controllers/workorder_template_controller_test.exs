defmodule Inconn2ServiceWeb.WorkorderTemplateControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderTemplate

  @create_attrs %{
    applicable_end: ~D[2010-04-17],
    applicable_start: ~D[2010-04-17],
    asset_category_id: 42,
    create_new: "some create_new",
    estimated_time: 42,
    max_times: 42,
    name: "some name",
    repeat_every: 42,
    repeat_unit: "some repeat_unit",
    scheduled: "some scheduled",
    task_list_id: 42,
    tasks: [],
    time_end: ~T[14:00:00],
    time_start: ~T[14:00:00],
    workorder_prior_time: 42
  }
  @update_attrs %{
    applicable_end: ~D[2011-05-18],
    applicable_start: ~D[2011-05-18],
    asset_category_id: 43,
    create_new: "some updated create_new",
    estimated_time: 43,
    max_times: 43,
    name: "some updated name",
    repeat_every: 43,
    repeat_unit: "some updated repeat_unit",
    scheduled: "some updated scheduled",
    task_list_id: 43,
    tasks: [],
    time_end: ~T[15:01:01],
    time_start: ~T[15:01:01],
    workorder_prior_time: 43
  }
  @invalid_attrs %{applicable_end: nil, applicable_start: nil, asset_category_id: nil, create_new: nil, estimated_time: nil, max_times: nil, name: nil, repeat_every: nil, repeat_unit: nil, scheduled: nil, task_list_id: nil, tasks: nil, time_end: nil, time_start: nil, workorder_prior_time: nil}

  def fixture(:workorder_template) do
    {:ok, workorder_template} = Workorder.create_workorder_template(@create_attrs)
    workorder_template
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workorder_templates", %{conn: conn} do
      conn = get(conn, Routes.workorder_template_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workorder_template" do
    test "renders workorder_template when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workorder_template_path(conn, :create), workorder_template: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workorder_template_path(conn, :show, id))

      assert %{
               "id" => id,
               "applicable_end" => "2010-04-17",
               "applicable_start" => "2010-04-17",
               "asset_category_id" => 42,
               "create_new" => "some create_new",
               "estimated_time" => 42,
               "max_times" => 42,
               "name" => "some name",
               "repeat_every" => 42,
               "repeat_unit" => "some repeat_unit",
               "scheduled" => "some scheduled",
               "task_list_id" => 42,
               "tasks" => [],
               "time_end" => "14:00:00",
               "time_start" => "14:00:00",
               "workorder_prior_time" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workorder_template_path(conn, :create), workorder_template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workorder_template" do
    setup [:create_workorder_template]

    test "renders workorder_template when data is valid", %{conn: conn, workorder_template: %WorkorderTemplate{id: id} = workorder_template} do
      conn = put(conn, Routes.workorder_template_path(conn, :update, workorder_template), workorder_template: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workorder_template_path(conn, :show, id))

      assert %{
               "id" => id,
               "applicable_end" => "2011-05-18",
               "applicable_start" => "2011-05-18",
               "asset_category_id" => 43,
               "create_new" => "some updated create_new",
               "estimated_time" => 43,
               "max_times" => 43,
               "name" => "some updated name",
               "repeat_every" => 43,
               "repeat_unit" => "some updated repeat_unit",
               "scheduled" => "some updated scheduled",
               "task_list_id" => 43,
               "tasks" => [],
               "time_end" => "15:01:01",
               "time_start" => "15:01:01",
               "workorder_prior_time" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workorder_template: workorder_template} do
      conn = put(conn, Routes.workorder_template_path(conn, :update, workorder_template), workorder_template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workorder_template" do
    setup [:create_workorder_template]

    test "deletes chosen workorder_template", %{conn: conn, workorder_template: workorder_template} do
      conn = delete(conn, Routes.workorder_template_path(conn, :delete, workorder_template))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workorder_template_path(conn, :show, workorder_template))
      end
    end
  end

  defp create_workorder_template(_) do
    workorder_template = fixture(:workorder_template)
    %{workorder_template: workorder_template}
  end
end

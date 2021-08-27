defmodule Inconn2ServiceWeb.WorkorderScheduleControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderSchedule

  @create_attrs %{
    config: "some config"
  }
  @update_attrs %{
    config: "some updated config"
  }
  @invalid_attrs %{config: nil}

  def fixture(:workorder_schedule) do
    {:ok, workorder_schedule} = Workorder.create_workorder_schedule(@create_attrs)
    workorder_schedule
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workorder_schedules", %{conn: conn} do
      conn = get(conn, Routes.workorder_schedule_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workorder_schedule" do
    test "renders workorder_schedule when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workorder_schedule_path(conn, :create), workorder_schedule: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workorder_schedule_path(conn, :show, id))

      assert %{
               "id" => id,
               "config" => "some config"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workorder_schedule_path(conn, :create), workorder_schedule: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workorder_schedule" do
    setup [:create_workorder_schedule]

    test "renders workorder_schedule when data is valid", %{conn: conn, workorder_schedule: %WorkorderSchedule{id: id} = workorder_schedule} do
      conn = put(conn, Routes.workorder_schedule_path(conn, :update, workorder_schedule), workorder_schedule: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workorder_schedule_path(conn, :show, id))

      assert %{
               "id" => id,
               "config" => "some updated config"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workorder_schedule: workorder_schedule} do
      conn = put(conn, Routes.workorder_schedule_path(conn, :update, workorder_schedule), workorder_schedule: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workorder_schedule" do
    setup [:create_workorder_schedule]

    test "deletes chosen workorder_schedule", %{conn: conn, workorder_schedule: workorder_schedule} do
      conn = delete(conn, Routes.workorder_schedule_path(conn, :delete, workorder_schedule))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workorder_schedule_path(conn, :show, workorder_schedule))
      end
    end
  end

  defp create_workorder_schedule(_) do
    workorder_schedule = fixture(:workorder_schedule)
    %{workorder_schedule: workorder_schedule}
  end
end

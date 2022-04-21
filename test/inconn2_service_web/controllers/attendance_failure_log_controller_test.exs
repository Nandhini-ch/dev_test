defmodule Inconn2ServiceWeb.AttendanceFailureLogControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.AttendanceFailureLog

  @create_attrs %{
    date_time: ~N[2010-04-17 14:00:00],
    employee_id: 42,
    failure_image: "some failure_image"
  }
  @update_attrs %{
    date_time: ~N[2011-05-18 15:01:01],
    employee_id: 43,
    failure_image: "some updated failure_image"
  }
  @invalid_attrs %{date_time: nil, employee_id: nil, failure_image: nil}

  def fixture(:attendance_failure_log) do
    {:ok, attendance_failure_log} = Assignment.create_attendance_failure_log(@create_attrs)
    attendance_failure_log
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all attendance_failure_logs", %{conn: conn} do
      conn = get(conn, Routes.attendance_failure_log_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create attendance_failure_log" do
    test "renders attendance_failure_log when data is valid", %{conn: conn} do
      conn = post(conn, Routes.attendance_failure_log_path(conn, :create), attendance_failure_log: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.attendance_failure_log_path(conn, :show, id))

      assert %{
               "id" => id,
               "date_time" => "2010-04-17T14:00:00",
               "employee_id" => 42,
               "failure_image" => "some failure_image"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.attendance_failure_log_path(conn, :create), attendance_failure_log: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update attendance_failure_log" do
    setup [:create_attendance_failure_log]

    test "renders attendance_failure_log when data is valid", %{conn: conn, attendance_failure_log: %AttendanceFailureLog{id: id} = attendance_failure_log} do
      conn = put(conn, Routes.attendance_failure_log_path(conn, :update, attendance_failure_log), attendance_failure_log: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.attendance_failure_log_path(conn, :show, id))

      assert %{
               "id" => id,
               "date_time" => "2011-05-18T15:01:01",
               "employee_id" => 43,
               "failure_image" => "some updated failure_image"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, attendance_failure_log: attendance_failure_log} do
      conn = put(conn, Routes.attendance_failure_log_path(conn, :update, attendance_failure_log), attendance_failure_log: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete attendance_failure_log" do
    setup [:create_attendance_failure_log]

    test "deletes chosen attendance_failure_log", %{conn: conn, attendance_failure_log: attendance_failure_log} do
      conn = delete(conn, Routes.attendance_failure_log_path(conn, :delete, attendance_failure_log))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.attendance_failure_log_path(conn, :show, attendance_failure_log))
      end
    end
  end

  defp create_attendance_failure_log(_) do
    attendance_failure_log = fixture(:attendance_failure_log)
    %{attendance_failure_log: attendance_failure_log}
  end
end

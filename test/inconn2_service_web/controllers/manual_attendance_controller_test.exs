defmodule Inconn2ServiceWeb.ManualAttendanceControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.ManualAttendance

  @create_attrs %{
    attendance_marked_by: 42,
    employee_id: 42,
    in_time: ~N[2010-04-17 14:00:00],
    is_overtime: true,
    out_time: ~N[2010-04-17 14:00:00],
    overtime_hours_in_minutes: 42,
    status: "some status",
    worked_hours_in_minutes: 42
  }
  @update_attrs %{
    attendance_marked_by: 43,
    employee_id: 43,
    in_time: ~N[2011-05-18 15:01:01],
    is_overtime: false,
    out_time: ~N[2011-05-18 15:01:01],
    overtime_hours_in_minutes: 43,
    status: "some updated status",
    worked_hours_in_minutes: 43
  }
  @invalid_attrs %{attendance_marked_by: nil, employee_id: nil, in_time: nil, is_overtime: nil, out_time: nil, overtime_hours_in_minutes: nil, status: nil, worked_hours_in_minutes: nil}

  def fixture(:manual_attendance) do
    {:ok, manual_attendance} = Assignment.create_manual_attendance(@create_attrs)
    manual_attendance
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all manual_attendances", %{conn: conn} do
      conn = get(conn, Routes.manual_attendance_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create manual_attendance" do
    test "renders manual_attendance when data is valid", %{conn: conn} do
      conn = post(conn, Routes.manual_attendance_path(conn, :create), manual_attendance: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.manual_attendance_path(conn, :show, id))

      assert %{
               "id" => id,
               "attendance_marked_by" => 42,
               "employee_id" => 42,
               "in_time" => "2010-04-17T14:00:00",
               "is_overtime" => true,
               "out_time" => "2010-04-17T14:00:00",
               "overtime_hours_in_minutes" => 42,
               "status" => "some status",
               "worked_hours_in_minutes" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.manual_attendance_path(conn, :create), manual_attendance: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update manual_attendance" do
    setup [:create_manual_attendance]

    test "renders manual_attendance when data is valid", %{conn: conn, manual_attendance: %ManualAttendance{id: id} = manual_attendance} do
      conn = put(conn, Routes.manual_attendance_path(conn, :update, manual_attendance), manual_attendance: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.manual_attendance_path(conn, :show, id))

      assert %{
               "id" => id,
               "attendance_marked_by" => 43,
               "employee_id" => 43,
               "in_time" => "2011-05-18T15:01:01",
               "is_overtime" => false,
               "out_time" => "2011-05-18T15:01:01",
               "overtime_hours_in_minutes" => 43,
               "status" => "some updated status",
               "worked_hours_in_minutes" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, manual_attendance: manual_attendance} do
      conn = put(conn, Routes.manual_attendance_path(conn, :update, manual_attendance), manual_attendance: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete manual_attendance" do
    setup [:create_manual_attendance]

    test "deletes chosen manual_attendance", %{conn: conn, manual_attendance: manual_attendance} do
      conn = delete(conn, Routes.manual_attendance_path(conn, :delete, manual_attendance))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.manual_attendance_path(conn, :show, manual_attendance))
      end
    end
  end

  defp create_manual_attendance(_) do
    manual_attendance = fixture(:manual_attendance)
    %{manual_attendance: manual_attendance}
  end
end

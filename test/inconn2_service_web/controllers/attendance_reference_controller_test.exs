defmodule Inconn2ServiceWeb.AttendanceReferenceControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.AttendanceReference

  @create_attrs %{
    employee_id: 42,
    reference_image: "some reference_image",
    status: "some status"
  }
  @update_attrs %{
    employee_id: 43,
    reference_image: "some updated reference_image",
    status: "some updated status"
  }
  @invalid_attrs %{employee_id: nil, reference_image: nil, status: nil}

  def fixture(:attendance_reference) do
    {:ok, attendance_reference} = Assignment.create_attendance_reference(@create_attrs)
    attendance_reference
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all attendance_references", %{conn: conn} do
      conn = get(conn, Routes.attendance_reference_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create attendance_reference" do
    test "renders attendance_reference when data is valid", %{conn: conn} do
      conn = post(conn, Routes.attendance_reference_path(conn, :create), attendance_reference: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.attendance_reference_path(conn, :show, id))

      assert %{
               "id" => id,
               "employee_id" => 42,
               "reference_image" => "some reference_image",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.attendance_reference_path(conn, :create), attendance_reference: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update attendance_reference" do
    setup [:create_attendance_reference]

    test "renders attendance_reference when data is valid", %{conn: conn, attendance_reference: %AttendanceReference{id: id} = attendance_reference} do
      conn = put(conn, Routes.attendance_reference_path(conn, :update, attendance_reference), attendance_reference: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.attendance_reference_path(conn, :show, id))

      assert %{
               "id" => id,
               "employee_id" => 43,
               "reference_image" => "some updated reference_image",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, attendance_reference: attendance_reference} do
      conn = put(conn, Routes.attendance_reference_path(conn, :update, attendance_reference), attendance_reference: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete attendance_reference" do
    setup [:create_attendance_reference]

    test "deletes chosen attendance_reference", %{conn: conn, attendance_reference: attendance_reference} do
      conn = delete(conn, Routes.attendance_reference_path(conn, :delete, attendance_reference))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.attendance_reference_path(conn, :show, attendance_reference))
      end
    end
  end

  defp create_attendance_reference(_) do
    attendance_reference = fixture(:attendance_reference)
    %{attendance_reference: attendance_reference}
  end
end

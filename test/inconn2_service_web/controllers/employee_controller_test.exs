defmodule Inconn2ServiceWeb.EmployeeControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Employee

  @create_attrs %{
    Emp_id: "some Emp_id",
    Landline_no: "some Landline_no",
    Mobile_no: "some Mobile_no",
    Salary: 120.5,
    designation: "some designation",
    email: "some email",
    employment_start_date: ~D[2010-04-17],
    employment_end_date: ~D[2010-04-17],
    first_name: "some first_name",
    has_login_credentials: true,
    last_name: "some last_name"
  }
  @update_attrs %{
    Emp_id: "some updated Emp_id",
    Landline_no: "some updated Landline_no",
    Mobile_no: "some updated Mobile_no",
    Salary: 456.7,
    designation: "some updated designation",
    email: "some updated email",
    employment_start_date: ~D[2011-05-18],
    employment_end_date: ~D[2011-05-18],
    first_name: "some updated first_name",
    has_login_credentials: false,
    last_name: "some updated last_name"
  }
  @invalid_attrs %{Emp_id: nil, Landline_no: nil, Mobile_no: nil, Salary: nil, designation: nil, email: nil, employment_start_date: nil, employment_end_date: nil, first_name: nil, has_login_credentials: nil, last_name: nil}

  def fixture(:employee) do
    {:ok, employee} = Staff.create_employee(@create_attrs)
    employee
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all employees", %{conn: conn} do
      conn = get(conn, Routes.employee_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create employee" do
    test "renders employee when data is valid", %{conn: conn} do
      conn = post(conn, Routes.employee_path(conn, :create), employee: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.employee_path(conn, :show, id))

      assert %{
               "id" => id,
               "Emp_id" => "some Emp_id",
               "Landline_no" => "some Landline_no",
               "Mobile_no" => "some Mobile_no",
               "Salary" => 120.5,
               "designation" => "some designation",
               "email" => "some email",
               "employment_start_date" => "2010-04-17",
               "employment_end_date" => "2010-04-17",
               "first_name" => "some first_name",
               "has_login_credentials" => true,
               "last_name" => "some last_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.employee_path(conn, :create), employee: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update employee" do
    setup [:create_employee]

    test "renders employee when data is valid", %{conn: conn, employee: %Employee{id: id} = employee} do
      conn = put(conn, Routes.employee_path(conn, :update, employee), employee: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.employee_path(conn, :show, id))

      assert %{
               "id" => id,
               "Emp_id" => "some updated Emp_id",
               "Landline_no" => "some updated Landline_no",
               "Mobile_no" => "some updated Mobile_no",
               "Salary" => 456.7,
               "designation" => "some updated designation",
               "email" => "some updated email",
               "employment_start_date" => "2011-05-18",
               "employment_end_date" => "2011-05-18",
               "first_name" => "some updated first_name",
               "has_login_credentials" => false,
               "last_name" => "some updated last_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, employee: employee} do
      conn = put(conn, Routes.employee_path(conn, :update, employee), employee: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete employee" do
    setup [:create_employee]

    test "deletes chosen employee", %{conn: conn, employee: employee} do
      conn = delete(conn, Routes.employee_path(conn, :delete, employee))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.employee_path(conn, :show, employee))
      end
    end
  end

  defp create_employee(_) do
    employee = fixture(:employee)
    %{employee: employee}
  end
end

defmodule Inconn2ServiceWeb.EmployeeRosterControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.EmployeeRoster

  @create_attrs %{
    end_date: ~D[2010-04-17],
    start_date: ~D[2010-04-17]
  }
  @update_attrs %{
    end_date: ~D[2011-05-18],
    start_date: ~D[2011-05-18]
  }
  @invalid_attrs %{end_date: nil, start_date: nil}

  def fixture(:employee_roster) do
    {:ok, employee_roster} = Assignment.create_employee_roster(@create_attrs)
    employee_roster
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all employee_rosters", %{conn: conn} do
      conn = get(conn, Routes.employee_roster_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create employee_roster" do
    test "renders employee_roster when data is valid", %{conn: conn} do
      conn = post(conn, Routes.employee_roster_path(conn, :create), employee_roster: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.employee_roster_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2010-04-17",
               "start_date" => "2010-04-17"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.employee_roster_path(conn, :create), employee_roster: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update employee_roster" do
    setup [:create_employee_roster]

    test "renders employee_roster when data is valid", %{conn: conn, employee_roster: %EmployeeRoster{id: id} = employee_roster} do
      conn = put(conn, Routes.employee_roster_path(conn, :update, employee_roster), employee_roster: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.employee_roster_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2011-05-18",
               "start_date" => "2011-05-18"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, employee_roster: employee_roster} do
      conn = put(conn, Routes.employee_roster_path(conn, :update, employee_roster), employee_roster: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete employee_roster" do
    setup [:create_employee_roster]

    test "deletes chosen employee_roster", %{conn: conn, employee_roster: employee_roster} do
      conn = delete(conn, Routes.employee_roster_path(conn, :delete, employee_roster))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.employee_roster_path(conn, :show, employee_roster))
      end
    end
  end

  defp create_employee_roster(_) do
    employee_roster = fixture(:employee_roster)
    %{employee_roster: employee_roster}
  end
end

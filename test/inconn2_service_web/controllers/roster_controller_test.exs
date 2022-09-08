defmodule Inconn2ServiceWeb.RosterControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Assignments
  alias Inconn2Service.Assignments.Roster

  @create_attrs %{
    active: true,
    date: ~D[2010-04-17],
    employee_id: 42,
    shift_id: 42
  }
  @update_attrs %{
    active: false,
    date: ~D[2011-05-18],
    employee_id: 43,
    shift_id: 43
  }
  @invalid_attrs %{active: nil, date: nil, employee_id: nil, shift_id: nil}

  def fixture(:roster) do
    {:ok, roster} = Assignments.create_roster(@create_attrs)
    roster
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all rosters", %{conn: conn} do
      conn = get(conn, Routes.roster_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create roster" do
    test "renders roster when data is valid", %{conn: conn} do
      conn = post(conn, Routes.roster_path(conn, :create), roster: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.roster_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => true,
               "date" => "2010-04-17",
               "employee_id" => 42,
               "shift_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.roster_path(conn, :create), roster: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update roster" do
    setup [:create_roster]

    test "renders roster when data is valid", %{conn: conn, roster: %Roster{id: id} = roster} do
      conn = put(conn, Routes.roster_path(conn, :update, roster), roster: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.roster_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => false,
               "date" => "2011-05-18",
               "employee_id" => 43,
               "shift_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, roster: roster} do
      conn = put(conn, Routes.roster_path(conn, :update, roster), roster: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete roster" do
    setup [:create_roster]

    test "deletes chosen roster", %{conn: conn, roster: roster} do
      conn = delete(conn, Routes.roster_path(conn, :delete, roster))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.roster_path(conn, :show, roster))
      end
    end
  end

  defp create_roster(_) do
    roster = fixture(:roster)
    %{roster: roster}
  end
end

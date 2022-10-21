defmodule Inconn2ServiceWeb.MasterRosterControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Assignments
  alias Inconn2Service.Assignments.MasterRoster

  @create_attrs %{
    active: true
  }
  @update_attrs %{
    active: false
  }
  @invalid_attrs %{active: nil}

  def fixture(:master_roster) do
    {:ok, master_roster} = Assignments.create_master_roster(@create_attrs)
    master_roster
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all master_rosters", %{conn: conn} do
      conn = get(conn, Routes.master_roster_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create master_roster" do
    test "renders master_roster when data is valid", %{conn: conn} do
      conn = post(conn, Routes.master_roster_path(conn, :create), master_roster: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.master_roster_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.master_roster_path(conn, :create), master_roster: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update master_roster" do
    setup [:create_master_roster]

    test "renders master_roster when data is valid", %{conn: conn, master_roster: %MasterRoster{id: id} = master_roster} do
      conn = put(conn, Routes.master_roster_path(conn, :update, master_roster), master_roster: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.master_roster_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, master_roster: master_roster} do
      conn = put(conn, Routes.master_roster_path(conn, :update, master_roster), master_roster: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete master_roster" do
    setup [:create_master_roster]

    test "deletes chosen master_roster", %{conn: conn, master_roster: master_roster} do
      conn = delete(conn, Routes.master_roster_path(conn, :delete, master_roster))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.master_roster_path(conn, :show, master_roster))
      end
    end
  end

  defp create_master_roster(_) do
    master_roster = fixture(:master_roster)
    %{master_roster: master_roster}
  end
end

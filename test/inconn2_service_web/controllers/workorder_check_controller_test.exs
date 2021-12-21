defmodule Inconn2ServiceWeb.WorkorderCheckControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderCheck

  @create_attrs %{
    approved: true,
    approved_by_user_id: 42,
    check_id: 42,
    remarks: "some remarks",
    type: "some type"
  }
  @update_attrs %{
    approved: false,
    approved_by_user_id: 43,
    check_id: 43,
    remarks: "some updated remarks",
    type: "some updated type"
  }
  @invalid_attrs %{approved: nil, approved_by_user_id: nil, check_id: nil, remarks: nil, type: nil}

  def fixture(:workorder_check) do
    {:ok, workorder_check} = Workorder.create_workorder_check(@create_attrs)
    workorder_check
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workorder_checks", %{conn: conn} do
      conn = get(conn, Routes.workorder_check_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workorder_check" do
    test "renders workorder_check when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workorder_check_path(conn, :create), workorder_check: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workorder_check_path(conn, :show, id))

      assert %{
               "id" => id,
               "approved" => true,
               "approved_by_user_id" => 42,
               "check_id" => 42,
               "remarks" => "some remarks",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workorder_check_path(conn, :create), workorder_check: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workorder_check" do
    setup [:create_workorder_check]

    test "renders workorder_check when data is valid", %{conn: conn, workorder_check: %WorkorderCheck{id: id} = workorder_check} do
      conn = put(conn, Routes.workorder_check_path(conn, :update, workorder_check), workorder_check: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workorder_check_path(conn, :show, id))

      assert %{
               "id" => id,
               "approved" => false,
               "approved_by_user_id" => 43,
               "check_id" => 43,
               "remarks" => "some updated remarks",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workorder_check: workorder_check} do
      conn = put(conn, Routes.workorder_check_path(conn, :update, workorder_check), workorder_check: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workorder_check" do
    setup [:create_workorder_check]

    test "deletes chosen workorder_check", %{conn: conn, workorder_check: workorder_check} do
      conn = delete(conn, Routes.workorder_check_path(conn, :delete, workorder_check))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workorder_check_path(conn, :show, workorder_check))
      end
    end
  end

  defp create_workorder_check(_) do
    workorder_check = fixture(:workorder_check)
    %{workorder_check: workorder_check}
  end
end

defmodule Inconn2ServiceWeb.WorkorderTaskControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderTask

  @create_attrs %{
    sequence: 42,
    task_id: 42
  }
  @update_attrs %{
    sequence: 43,
    task_id: 43
  }
  @invalid_attrs %{sequence: nil, task_id: nil}

  def fixture(:workorder_task) do
    {:ok, workorder_task} = Workorder.create_workorder_task(@create_attrs)
    workorder_task
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workorder_tasks", %{conn: conn} do
      conn = get(conn, Routes.workorder_task_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workorder_task" do
    test "renders workorder_task when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workorder_task_path(conn, :create), workorder_task: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workorder_task_path(conn, :show, id))

      assert %{
               "id" => id,
               "sequence" => 42,
               "task_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workorder_task_path(conn, :create), workorder_task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workorder_task" do
    setup [:create_workorder_task]

    test "renders workorder_task when data is valid", %{conn: conn, workorder_task: %WorkorderTask{id: id} = workorder_task} do
      conn = put(conn, Routes.workorder_task_path(conn, :update, workorder_task), workorder_task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workorder_task_path(conn, :show, id))

      assert %{
               "id" => id,
               "sequence" => 43,
               "task_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workorder_task: workorder_task} do
      conn = put(conn, Routes.workorder_task_path(conn, :update, workorder_task), workorder_task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workorder_task" do
    setup [:create_workorder_task]

    test "deletes chosen workorder_task", %{conn: conn, workorder_task: workorder_task} do
      conn = delete(conn, Routes.workorder_task_path(conn, :delete, workorder_task))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workorder_task_path(conn, :show, workorder_task))
      end
    end
  end

  defp create_workorder_task(_) do
    workorder_task = fixture(:workorder_task)
    %{workorder_task: workorder_task}
  end
end

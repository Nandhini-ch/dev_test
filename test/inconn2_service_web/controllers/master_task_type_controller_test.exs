defmodule Inconn2ServiceWeb.MasterTaskTypeControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.WorkOrderConfig.MasterTaskType

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:master_task_type) do
    {:ok, master_task_type} = WorkOrderConfig.create_master_task_type(@create_attrs)
    master_task_type
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all master_task_types", %{conn: conn} do
      conn = get(conn, Routes.master_task_type_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create master_task_type" do
    test "renders master_task_type when data is valid", %{conn: conn} do
      conn = post(conn, Routes.master_task_type_path(conn, :create), master_task_type: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.master_task_type_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.master_task_type_path(conn, :create), master_task_type: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update master_task_type" do
    setup [:create_master_task_type]

    test "renders master_task_type when data is valid", %{conn: conn, master_task_type: %MasterTaskType{id: id} = master_task_type} do
      conn = put(conn, Routes.master_task_type_path(conn, :update, master_task_type), master_task_type: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.master_task_type_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, master_task_type: master_task_type} do
      conn = put(conn, Routes.master_task_type_path(conn, :update, master_task_type), master_task_type: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete master_task_type" do
    setup [:create_master_task_type]

    test "deletes chosen master_task_type", %{conn: conn, master_task_type: master_task_type} do
      conn = delete(conn, Routes.master_task_type_path(conn, :delete, master_task_type))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.master_task_type_path(conn, :show, master_task_type))
      end
    end
  end

  defp create_master_task_type(_) do
    master_task_type = fixture(:master_task_type)
    %{master_task_type: master_task_type}
  end
end

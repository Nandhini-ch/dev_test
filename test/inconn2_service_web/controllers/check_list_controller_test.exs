defmodule Inconn2ServiceWeb.CheckListControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.CheckListConfig.CheckList

  @create_attrs %{
    check_id: [],
    name: "some name",
    type: "some type"
  }
  @update_attrs %{
    check_id: [],
    name: "some updated name",
    type: "some updated type"
  }
  @invalid_attrs %{check_id: nil, name: nil, type: nil}

  def fixture(:check_list) do
    {:ok, check_list} = CheckListConfig.create_check_list(@create_attrs)
    check_list
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all check_lists", %{conn: conn} do
      conn = get(conn, Routes.check_list_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create check_list" do
    test "renders check_list when data is valid", %{conn: conn} do
      conn = post(conn, Routes.check_list_path(conn, :create), check_list: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.check_list_path(conn, :show, id))

      assert %{
               "id" => id,
               "check_id" => [],
               "name" => "some name",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.check_list_path(conn, :create), check_list: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update check_list" do
    setup [:create_check_list]

    test "renders check_list when data is valid", %{conn: conn, check_list: %CheckList{id: id} = check_list} do
      conn = put(conn, Routes.check_list_path(conn, :update, check_list), check_list: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.check_list_path(conn, :show, id))

      assert %{
               "id" => id,
               "check_id" => [],
               "name" => "some updated name",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, check_list: check_list} do
      conn = put(conn, Routes.check_list_path(conn, :update, check_list), check_list: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete check_list" do
    setup [:create_check_list]

    test "deletes chosen check_list", %{conn: conn, check_list: check_list} do
      conn = delete(conn, Routes.check_list_path(conn, :delete, check_list))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.check_list_path(conn, :show, check_list))
      end
    end
  end

  defp create_check_list(_) do
    check_list = fixture(:check_list)
    %{check_list: check_list}
  end
end

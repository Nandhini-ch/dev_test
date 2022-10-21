defmodule Inconn2ServiceWeb.CheckTypeControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.CheckListConfig.CheckType

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:check_type) do
    {:ok, check_type} = CheckListConfig.create_check_type(@create_attrs)
    check_type
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all check_types", %{conn: conn} do
      conn = get(conn, Routes.check_type_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create check_type" do
    test "renders check_type when data is valid", %{conn: conn} do
      conn = post(conn, Routes.check_type_path(conn, :create), check_type: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.check_type_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.check_type_path(conn, :create), check_type: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update check_type" do
    setup [:create_check_type]

    test "renders check_type when data is valid", %{conn: conn, check_type: %CheckType{id: id} = check_type} do
      conn = put(conn, Routes.check_type_path(conn, :update, check_type), check_type: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.check_type_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, check_type: check_type} do
      conn = put(conn, Routes.check_type_path(conn, :update, check_type), check_type: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete check_type" do
    setup [:create_check_type]

    test "deletes chosen check_type", %{conn: conn, check_type: check_type} do
      conn = delete(conn, Routes.check_type_path(conn, :delete, check_type))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.check_type_path(conn, :show, check_type))
      end
    end
  end

  defp create_check_type(_) do
    check_type = fixture(:check_type)
    %{check_type: check_type}
  end
end

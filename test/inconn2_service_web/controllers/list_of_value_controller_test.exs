defmodule Inconn2ServiceWeb.ListOfValueControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Common
  alias Inconn2Service.Common.ListOfValue

  @create_attrs %{
    name: "some name",
    values: []
  }
  @update_attrs %{
    name: "some updated name",
    values: []
  }
  @invalid_attrs %{name: nil, values: nil}

  def fixture(:list_of_value) do
    {:ok, list_of_value} = Common.create_list_of_value(@create_attrs)
    list_of_value
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all list_of_values", %{conn: conn} do
      conn = get(conn, Routes.list_of_value_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create list_of_value" do
    test "renders list_of_value when data is valid", %{conn: conn} do
      conn = post(conn, Routes.list_of_value_path(conn, :create), list_of_value: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.list_of_value_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name",
               "values" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.list_of_value_path(conn, :create), list_of_value: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update list_of_value" do
    setup [:create_list_of_value]

    test "renders list_of_value when data is valid", %{conn: conn, list_of_value: %ListOfValue{id: id} = list_of_value} do
      conn = put(conn, Routes.list_of_value_path(conn, :update, list_of_value), list_of_value: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.list_of_value_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name",
               "values" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, list_of_value: list_of_value} do
      conn = put(conn, Routes.list_of_value_path(conn, :update, list_of_value), list_of_value: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete list_of_value" do
    setup [:create_list_of_value]

    test "deletes chosen list_of_value", %{conn: conn, list_of_value: list_of_value} do
      conn = delete(conn, Routes.list_of_value_path(conn, :delete, list_of_value))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.list_of_value_path(conn, :show, list_of_value))
      end
    end
  end

  defp create_list_of_value(_) do
    list_of_value = fixture(:list_of_value)
    %{list_of_value: list_of_value}
  end
end

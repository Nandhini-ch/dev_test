defmodule Inconn2ServiceWeb.CustomFieldsControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Custom
  alias Inconn2Service.Custom.CustomFields

  @create_attrs %{
    entity: "some entity",
    fields: []
  }
  @update_attrs %{
    entity: "some updated entity",
    fields: []
  }
  @invalid_attrs %{entity: nil, fields: nil}

  def fixture(:custom_fields) do
    {:ok, custom_fields} = Custom.create_custom_fields(@create_attrs)
    custom_fields
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all custom_fields", %{conn: conn} do
      conn = get(conn, Routes.custom_fields_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create custom_fields" do
    test "renders custom_fields when data is valid", %{conn: conn} do
      conn = post(conn, Routes.custom_fields_path(conn, :create), custom_fields: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.custom_fields_path(conn, :show, id))

      assert %{
               "id" => id,
               "entity" => "some entity",
               "fields" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.custom_fields_path(conn, :create), custom_fields: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update custom_fields" do
    setup [:create_custom_fields]

    test "renders custom_fields when data is valid", %{conn: conn, custom_fields: %CustomFields{id: id} = custom_fields} do
      conn = put(conn, Routes.custom_fields_path(conn, :update, custom_fields), custom_fields: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.custom_fields_path(conn, :show, id))

      assert %{
               "id" => id,
               "entity" => "some updated entity",
               "fields" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, custom_fields: custom_fields} do
      conn = put(conn, Routes.custom_fields_path(conn, :update, custom_fields), custom_fields: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete custom_fields" do
    setup [:create_custom_fields]

    test "deletes chosen custom_fields", %{conn: conn, custom_fields: custom_fields} do
      conn = delete(conn, Routes.custom_fields_path(conn, :delete, custom_fields))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.custom_fields_path(conn, :show, custom_fields))
      end
    end
  end

  defp create_custom_fields(_) do
    custom_fields = fixture(:custom_fields)
    %{custom_fields: custom_fields}
  end
end

defmodule Inconn2ServiceWeb.WidgetControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Common
  alias Inconn2Service.Common.Widget

  @create_attrs %{
    code: "some code",
    description: "some description",
    title: "some title"
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    title: "some updated title"
  }
  @invalid_attrs %{code: nil, description: nil, title: nil}

  def fixture(:widget) do
    {:ok, widget} = Common.create_widget(@create_attrs)
    widget
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all widgets", %{conn: conn} do
      conn = get(conn, Routes.widget_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create widget" do
    test "renders widget when data is valid", %{conn: conn} do
      conn = post(conn, Routes.widget_path(conn, :create), widget: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.widget_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some code",
               "description" => "some description",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.widget_path(conn, :create), widget: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update widget" do
    setup [:create_widget]

    test "renders widget when data is valid", %{conn: conn, widget: %Widget{id: id} = widget} do
      conn = put(conn, Routes.widget_path(conn, :update, widget), widget: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.widget_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some updated code",
               "description" => "some updated description",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, widget: widget} do
      conn = put(conn, Routes.widget_path(conn, :update, widget), widget: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete widget" do
    setup [:create_widget]

    test "deletes chosen widget", %{conn: conn, widget: widget} do
      conn = delete(conn, Routes.widget_path(conn, :delete, widget))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.widget_path(conn, :show, widget))
      end
    end
  end

  defp create_widget(_) do
    widget = fixture(:widget)
    %{widget: widget}
  end
end

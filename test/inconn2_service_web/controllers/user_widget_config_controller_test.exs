defmodule Inconn2ServiceWeb.UserWidgetConfigControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.DashboardConfiguration
  alias Inconn2Service.DashboardConfiguration.UserWidgetConfig

  @create_attrs %{
    position: 42,
    widget_code: "some widget_code"
  }
  @update_attrs %{
    position: 43,
    widget_code: "some updated widget_code"
  }
  @invalid_attrs %{position: nil, widget_code: nil}

  def fixture(:user_widget_config) do
    {:ok, user_widget_config} = DashboardConfiguration.create_user_widget_config(@create_attrs)
    user_widget_config
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_widget_configs", %{conn: conn} do
      conn = get(conn, Routes.user_widget_config_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_widget_config" do
    test "renders user_widget_config when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_widget_config_path(conn, :create), user_widget_config: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_widget_config_path(conn, :show, id))

      assert %{
               "id" => id,
               "position" => 42,
               "widget_code" => "some widget_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_widget_config_path(conn, :create), user_widget_config: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_widget_config" do
    setup [:create_user_widget_config]

    test "renders user_widget_config when data is valid", %{conn: conn, user_widget_config: %UserWidgetConfig{id: id} = user_widget_config} do
      conn = put(conn, Routes.user_widget_config_path(conn, :update, user_widget_config), user_widget_config: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_widget_config_path(conn, :show, id))

      assert %{
               "id" => id,
               "position" => 43,
               "widget_code" => "some updated widget_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user_widget_config: user_widget_config} do
      conn = put(conn, Routes.user_widget_config_path(conn, :update, user_widget_config), user_widget_config: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_widget_config" do
    setup [:create_user_widget_config]

    test "deletes chosen user_widget_config", %{conn: conn, user_widget_config: user_widget_config} do
      conn = delete(conn, Routes.user_widget_config_path(conn, :delete, user_widget_config))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_widget_config_path(conn, :show, user_widget_config))
      end
    end
  end

  defp create_user_widget_config(_) do
    user_widget_config = fixture(:user_widget_config)
    %{user_widget_config: user_widget_config}
  end
end

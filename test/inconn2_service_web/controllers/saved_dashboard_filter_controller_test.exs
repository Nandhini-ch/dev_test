defmodule Inconn2ServiceWeb.SavedDashboardFilterControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.DashboardConfiguration
  alias Inconn2Service.DashboardConfiguration.SavedDashboardFilter

  @create_attrs %{
    config: %{},
    site_id: 42,
    user_id: 42,
    widget_code: "some widget_code"
  }
  @update_attrs %{
    config: %{},
    site_id: 43,
    user_id: 43,
    widget_code: "some updated widget_code"
  }
  @invalid_attrs %{config: nil, site_id: nil, user_id: nil, widget_code: nil}

  def fixture(:saved_dashboard_filter) do
    {:ok, saved_dashboard_filter} = DashboardConfiguration.create_saved_dashboard_filter(@create_attrs)
    saved_dashboard_filter
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all saved_dashboard_filters", %{conn: conn} do
      conn = get(conn, Routes.saved_dashboard_filter_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create saved_dashboard_filter" do
    test "renders saved_dashboard_filter when data is valid", %{conn: conn} do
      conn = post(conn, Routes.saved_dashboard_filter_path(conn, :create), saved_dashboard_filter: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.saved_dashboard_filter_path(conn, :show, id))

      assert %{
               "id" => id,
               "config" => %{},
               "site_id" => 42,
               "user_id" => 42,
               "widget_code" => "some widget_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.saved_dashboard_filter_path(conn, :create), saved_dashboard_filter: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update saved_dashboard_filter" do
    setup [:create_saved_dashboard_filter]

    test "renders saved_dashboard_filter when data is valid", %{conn: conn, saved_dashboard_filter: %SavedDashboardFilter{id: id} = saved_dashboard_filter} do
      conn = put(conn, Routes.saved_dashboard_filter_path(conn, :update, saved_dashboard_filter), saved_dashboard_filter: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.saved_dashboard_filter_path(conn, :show, id))

      assert %{
               "id" => id,
               "config" => %{},
               "site_id" => 43,
               "user_id" => 43,
               "widget_code" => "some updated widget_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, saved_dashboard_filter: saved_dashboard_filter} do
      conn = put(conn, Routes.saved_dashboard_filter_path(conn, :update, saved_dashboard_filter), saved_dashboard_filter: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete saved_dashboard_filter" do
    setup [:create_saved_dashboard_filter]

    test "deletes chosen saved_dashboard_filter", %{conn: conn, saved_dashboard_filter: saved_dashboard_filter} do
      conn = delete(conn, Routes.saved_dashboard_filter_path(conn, :delete, saved_dashboard_filter))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.saved_dashboard_filter_path(conn, :show, saved_dashboard_filter))
      end
    end
  end

  defp create_saved_dashboard_filter(_) do
    saved_dashboard_filter = fixture(:saved_dashboard_filter)
    %{saved_dashboard_filter: saved_dashboard_filter}
  end
end

defmodule Inconn2ServiceWeb.AlertNotificationReserveControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Common
  alias Inconn2Service.Common.AlertNotificationReserve

  @create_attrs %{
    addressed_to_user_ids: [],
    code: "some code",
    description: "some description",
    module: "some module",
    type: "some type"
  }
  @update_attrs %{
    addressed_to_user_ids: [],
    code: "some updated code",
    description: "some updated description",
    module: "some updated module",
    type: "some updated type"
  }
  @invalid_attrs %{addressed_to_user_ids: nil, code: nil, description: nil, module: nil, type: nil}

  def fixture(:alert_notification_reserve) do
    {:ok, alert_notification_reserve} = Common.create_alert_notification_reserve(@create_attrs)
    alert_notification_reserve
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all alert_notification_reserves", %{conn: conn} do
      conn = get(conn, Routes.alert_notification_reserve_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create alert_notification_reserve" do
    test "renders alert_notification_reserve when data is valid", %{conn: conn} do
      conn = post(conn, Routes.alert_notification_reserve_path(conn, :create), alert_notification_reserve: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.alert_notification_reserve_path(conn, :show, id))

      assert %{
               "id" => id,
               "addressed_to_user_ids" => [],
               "code" => "some code",
               "description" => "some description",
               "module" => "some module",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.alert_notification_reserve_path(conn, :create), alert_notification_reserve: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update alert_notification_reserve" do
    setup [:create_alert_notification_reserve]

    test "renders alert_notification_reserve when data is valid", %{conn: conn, alert_notification_reserve: %AlertNotificationReserve{id: id} = alert_notification_reserve} do
      conn = put(conn, Routes.alert_notification_reserve_path(conn, :update, alert_notification_reserve), alert_notification_reserve: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.alert_notification_reserve_path(conn, :show, id))

      assert %{
               "id" => id,
               "addressed_to_user_ids" => [],
               "code" => "some updated code",
               "description" => "some updated description",
               "module" => "some updated module",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, alert_notification_reserve: alert_notification_reserve} do
      conn = put(conn, Routes.alert_notification_reserve_path(conn, :update, alert_notification_reserve), alert_notification_reserve: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete alert_notification_reserve" do
    setup [:create_alert_notification_reserve]

    test "deletes chosen alert_notification_reserve", %{conn: conn, alert_notification_reserve: alert_notification_reserve} do
      conn = delete(conn, Routes.alert_notification_reserve_path(conn, :delete, alert_notification_reserve))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.alert_notification_reserve_path(conn, :show, alert_notification_reserve))
      end
    end
  end

  defp create_alert_notification_reserve(_) do
    alert_notification_reserve = fixture(:alert_notification_reserve)
    %{alert_notification_reserve: alert_notification_reserve}
  end
end

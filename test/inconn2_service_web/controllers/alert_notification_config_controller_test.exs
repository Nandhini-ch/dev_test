defmodule Inconn2ServiceWeb.AlertNotificationConfigControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Prompt
  alias Inconn2Service.Prompt.AlertNotificationConfig

  @create_attrs %{
    addressed_to_user_ids: [],
    alert_notification_reserve_id: 42
  }
  @update_attrs %{
    addressed_to_user_ids: [],
    alert_notification_reserve_id: 43
  }
  @invalid_attrs %{addressed_to_user_ids: nil, alert_notification_reserve_id: nil}

  def fixture(:alert_notification_config) do
    {:ok, alert_notification_config} = Prompt.create_alert_notification_config(@create_attrs)
    alert_notification_config
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all alert_notification_configs", %{conn: conn} do
      conn = get(conn, Routes.alert_notification_config_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create alert_notification_config" do
    test "renders alert_notification_config when data is valid", %{conn: conn} do
      conn = post(conn, Routes.alert_notification_config_path(conn, :create), alert_notification_config: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.alert_notification_config_path(conn, :show, id))

      assert %{
               "id" => id,
               "addressed_to_user_ids" => [],
               "alert_notification_reserve_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.alert_notification_config_path(conn, :create), alert_notification_config: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update alert_notification_config" do
    setup [:create_alert_notification_config]

    test "renders alert_notification_config when data is valid", %{conn: conn, alert_notification_config: %AlertNotificationConfig{id: id} = alert_notification_config} do
      conn = put(conn, Routes.alert_notification_config_path(conn, :update, alert_notification_config), alert_notification_config: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.alert_notification_config_path(conn, :show, id))

      assert %{
               "id" => id,
               "addressed_to_user_ids" => [],
               "alert_notification_reserve_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, alert_notification_config: alert_notification_config} do
      conn = put(conn, Routes.alert_notification_config_path(conn, :update, alert_notification_config), alert_notification_config: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete alert_notification_config" do
    setup [:create_alert_notification_config]

    test "deletes chosen alert_notification_config", %{conn: conn, alert_notification_config: alert_notification_config} do
      conn = delete(conn, Routes.alert_notification_config_path(conn, :delete, alert_notification_config))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.alert_notification_config_path(conn, :show, alert_notification_config))
      end
    end
  end

  defp create_alert_notification_config(_) do
    alert_notification_config = fixture(:alert_notification_config)
    %{alert_notification_config: alert_notification_config}
  end
end

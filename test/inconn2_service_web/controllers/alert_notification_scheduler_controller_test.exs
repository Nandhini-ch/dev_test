defmodule Inconn2ServiceWeb.AlertNotificationSchedulerControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Common
  alias Inconn2Service.Common.AlertNotificationScheduler

  @create_attrs %{
    alert_code: "some alert_code",
    alert_identifier_date_time: ~N[2010-04-17 14:00:00],
    escalation_at_date_time: ~N[2010-04-17 14:00:00],
    site_id: 42
  }
  @update_attrs %{
    alert_code: "some updated alert_code",
    alert_identifier_date_time: ~N[2011-05-18 15:01:01],
    escalation_at_date_time: ~N[2011-05-18 15:01:01],
    site_id: 43
  }
  @invalid_attrs %{alert_code: nil, alert_identifier_date_time: nil, escalation_at_date_time: nil, site_id: nil}

  def fixture(:alert_notification_scheduler) do
    {:ok, alert_notification_scheduler} = Common.create_alert_notification_scheduler(@create_attrs)
    alert_notification_scheduler
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all alert_notification_schedulers", %{conn: conn} do
      conn = get(conn, Routes.alert_notification_scheduler_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create alert_notification_scheduler" do
    test "renders alert_notification_scheduler when data is valid", %{conn: conn} do
      conn = post(conn, Routes.alert_notification_scheduler_path(conn, :create), alert_notification_scheduler: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.alert_notification_scheduler_path(conn, :show, id))

      assert %{
               "id" => id,
               "alert_code" => "some alert_code",
               "alert_identifier_date_time" => "2010-04-17T14:00:00",
               "escalation_at_date_time" => "2010-04-17T14:00:00",
               "site_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.alert_notification_scheduler_path(conn, :create), alert_notification_scheduler: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update alert_notification_scheduler" do
    setup [:create_alert_notification_scheduler]

    test "renders alert_notification_scheduler when data is valid", %{conn: conn, alert_notification_scheduler: %AlertNotificationScheduler{id: id} = alert_notification_scheduler} do
      conn = put(conn, Routes.alert_notification_scheduler_path(conn, :update, alert_notification_scheduler), alert_notification_scheduler: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.alert_notification_scheduler_path(conn, :show, id))

      assert %{
               "id" => id,
               "alert_code" => "some updated alert_code",
               "alert_identifier_date_time" => "2011-05-18T15:01:01",
               "escalation_at_date_time" => "2011-05-18T15:01:01",
               "site_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, alert_notification_scheduler: alert_notification_scheduler} do
      conn = put(conn, Routes.alert_notification_scheduler_path(conn, :update, alert_notification_scheduler), alert_notification_scheduler: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete alert_notification_scheduler" do
    setup [:create_alert_notification_scheduler]

    test "deletes chosen alert_notification_scheduler", %{conn: conn, alert_notification_scheduler: alert_notification_scheduler} do
      conn = delete(conn, Routes.alert_notification_scheduler_path(conn, :delete, alert_notification_scheduler))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.alert_notification_scheduler_path(conn, :show, alert_notification_scheduler))
      end
    end
  end

  defp create_alert_notification_scheduler(_) do
    alert_notification_scheduler = fixture(:alert_notification_scheduler)
    %{alert_notification_scheduler: alert_notification_scheduler}
  end
end

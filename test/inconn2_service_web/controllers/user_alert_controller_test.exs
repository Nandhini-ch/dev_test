defmodule Inconn2ServiceWeb.UserAlertControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Prompt
  alias Inconn2Service.Prompt.UserAlert

  @create_attrs %{
    alert_id: 42,
    alert_type: "some alert_type",
    asset_id: 42,
    user_id: 42
  }
  @update_attrs %{
    alert_id: 43,
    alert_type: "some updated alert_type",
    asset_id: 43,
    user_id: 43
  }
  @invalid_attrs %{alert_id: nil, alert_type: nil, asset_id: nil, user_id: nil}

  def fixture(:user_alert) do
    {:ok, user_alert} = Prompt.create_user_alert(@create_attrs)
    user_alert
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_alerts", %{conn: conn} do
      conn = get(conn, Routes.user_alert_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_alert" do
    test "renders user_alert when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_alert_path(conn, :create), user_alert: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_alert_path(conn, :show, id))

      assert %{
               "id" => id,
               "alert_id" => 42,
               "alert_type" => "some alert_type",
               "asset_id" => 42,
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_alert_path(conn, :create), user_alert: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_alert" do
    setup [:create_user_alert]

    test "renders user_alert when data is valid", %{conn: conn, user_alert: %UserAlert{id: id} = user_alert} do
      conn = put(conn, Routes.user_alert_path(conn, :update, user_alert), user_alert: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_alert_path(conn, :show, id))

      assert %{
               "id" => id,
               "alert_id" => 43,
               "alert_type" => "some updated alert_type",
               "asset_id" => 43,
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user_alert: user_alert} do
      conn = put(conn, Routes.user_alert_path(conn, :update, user_alert), user_alert: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_alert" do
    setup [:create_user_alert]

    test "deletes chosen user_alert", %{conn: conn, user_alert: user_alert} do
      conn = delete(conn, Routes.user_alert_path(conn, :delete, user_alert))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_alert_path(conn, :show, user_alert))
      end
    end
  end

  defp create_user_alert(_) do
    user_alert = fixture(:user_alert)
    %{user_alert: user_alert}
  end
end

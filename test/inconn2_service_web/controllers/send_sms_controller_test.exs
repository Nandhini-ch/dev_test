defmodule Inconn2ServiceWeb.SendSmsControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Communication
  alias Inconn2Service.Communication.SendSms

  @create_attrs %{
    delivery_status: "some delivery_status",
    error_code: "some error_code",
    error_message: "some error_message",
    job_id: "some job_id",
    message: "some message",
    message_id: "some message_id",
    mobile_no: "some mobile_no",
    template_id: "some template_id",
    user_id: 42
  }
  @update_attrs %{
    delivery_status: "some updated delivery_status",
    error_code: "some updated error_code",
    error_message: "some updated error_message",
    job_id: "some updated job_id",
    message: "some updated message",
    message_id: "some updated message_id",
    mobile_no: "some updated mobile_no",
    template_id: "some updated template_id",
    user_id: 43
  }
  @invalid_attrs %{delivery_status: nil, error_code: nil, error_message: nil, job_id: nil, message: nil, message_id: nil, mobile_no: nil, template_id: nil, user_id: nil}

  def fixture(:send_sms) do
    {:ok, send_sms} = Communication.create_send_sms(@create_attrs)
    send_sms
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all send_sms", %{conn: conn} do
      conn = get(conn, Routes.send_sms_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create send_sms" do
    test "renders send_sms when data is valid", %{conn: conn} do
      conn = post(conn, Routes.send_sms_path(conn, :create), send_sms: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.send_sms_path(conn, :show, id))

      assert %{
               "id" => id,
               "delivery_status" => "some delivery_status",
               "error_code" => "some error_code",
               "error_message" => "some error_message",
               "job_id" => "some job_id",
               "message" => "some message",
               "message_id" => "some message_id",
               "mobile_no" => "some mobile_no",
               "template_id" => "some template_id",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.send_sms_path(conn, :create), send_sms: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update send_sms" do
    setup [:create_send_sms]

    test "renders send_sms when data is valid", %{conn: conn, send_sms: %SendSms{id: id} = send_sms} do
      conn = put(conn, Routes.send_sms_path(conn, :update, send_sms), send_sms: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.send_sms_path(conn, :show, id))

      assert %{
               "id" => id,
               "delivery_status" => "some updated delivery_status",
               "error_code" => "some updated error_code",
               "error_message" => "some updated error_message",
               "job_id" => "some updated job_id",
               "message" => "some updated message",
               "message_id" => "some updated message_id",
               "mobile_no" => "some updated mobile_no",
               "template_id" => "some updated template_id",
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, send_sms: send_sms} do
      conn = put(conn, Routes.send_sms_path(conn, :update, send_sms), send_sms: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete send_sms" do
    setup [:create_send_sms]

    test "deletes chosen send_sms", %{conn: conn, send_sms: send_sms} do
      conn = delete(conn, Routes.send_sms_path(conn, :delete, send_sms))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.send_sms_path(conn, :show, send_sms))
      end
    end
  end

  defp create_send_sms(_) do
    send_sms = fixture(:send_sms)
    %{send_sms: send_sms}
  end
end

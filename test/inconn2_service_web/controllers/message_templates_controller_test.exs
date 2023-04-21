defmodule Inconn2ServiceWeb.MessageTemplatesControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Communication
  alias Inconn2Service.Communication.MessageTemplates

  @create_attrs %{
    message: "some message"
  }
  @update_attrs %{
    message: "some updated message"
  }
  @invalid_attrs %{message: nil}

  def fixture(:message_templates) do
    {:ok, message_templates} = Communication.create_message_templates(@create_attrs)
    message_templates
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all message_templates", %{conn: conn} do
      conn = get(conn, Routes.message_templates_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create message_templates" do
    test "renders message_templates when data is valid", %{conn: conn} do
      conn = post(conn, Routes.message_templates_path(conn, :create), message_templates: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.message_templates_path(conn, :show, id))

      assert %{
               "id" => id,
               "message" => "some message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.message_templates_path(conn, :create), message_templates: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update message_templates" do
    setup [:create_message_templates]

    test "renders message_templates when data is valid", %{conn: conn, message_templates: %MessageTemplates{id: id} = message_templates} do
      conn = put(conn, Routes.message_templates_path(conn, :update, message_templates), message_templates: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.message_templates_path(conn, :show, id))

      assert %{
               "id" => id,
               "message" => "some updated message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, message_templates: message_templates} do
      conn = put(conn, Routes.message_templates_path(conn, :update, message_templates), message_templates: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete message_templates" do
    setup [:create_message_templates]

    test "deletes chosen message_templates", %{conn: conn, message_templates: message_templates} do
      conn = delete(conn, Routes.message_templates_path(conn, :delete, message_templates))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.message_templates_path(conn, :show, message_templates))
      end
    end
  end

  defp create_message_templates(_) do
    message_templates = fixture(:message_templates)
    %{message_templates: message_templates}
  end
end

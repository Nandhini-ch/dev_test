defmodule Inconn2ServiceWeb.EquipmentAttachmentControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentAttachment

  @create_attrs %{
    attachment: "some attachment",
    attachment_type: "some attachment_type",
    name: "some name"
  }
  @update_attrs %{
    attachment: "some updated attachment",
    attachment_type: "some updated attachment_type",
    name: "some updated name"
  }
  @invalid_attrs %{attachment: nil, attachment_type: nil, name: nil}

  def fixture(:equipment_attachment) do
    {:ok, equipment_attachment} = AssetInfo.create_equipment_attachment(@create_attrs)
    equipment_attachment
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all equipment_attachments", %{conn: conn} do
      conn = get(conn, Routes.equipment_attachment_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create equipment_attachment" do
    test "renders equipment_attachment when data is valid", %{conn: conn} do
      conn = post(conn, Routes.equipment_attachment_path(conn, :create), equipment_attachment: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.equipment_attachment_path(conn, :show, id))

      assert %{
               "id" => id,
               "attachment" => "some attachment",
               "attachment_type" => "some attachment_type",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.equipment_attachment_path(conn, :create), equipment_attachment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update equipment_attachment" do
    setup [:create_equipment_attachment]

    test "renders equipment_attachment when data is valid", %{conn: conn, equipment_attachment: %EquipmentAttachment{id: id} = equipment_attachment} do
      conn = put(conn, Routes.equipment_attachment_path(conn, :update, equipment_attachment), equipment_attachment: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.equipment_attachment_path(conn, :show, id))

      assert %{
               "id" => id,
               "attachment" => "some updated attachment",
               "attachment_type" => "some updated attachment_type",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, equipment_attachment: equipment_attachment} do
      conn = put(conn, Routes.equipment_attachment_path(conn, :update, equipment_attachment), equipment_attachment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete equipment_attachment" do
    setup [:create_equipment_attachment]

    test "deletes chosen equipment_attachment", %{conn: conn, equipment_attachment: equipment_attachment} do
      conn = delete(conn, Routes.equipment_attachment_path(conn, :delete, equipment_attachment))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.equipment_attachment_path(conn, :show, equipment_attachment))
      end
    end
  end

  defp create_equipment_attachment(_) do
    equipment_attachment = fixture(:equipment_attachment)
    %{equipment_attachment: equipment_attachment}
  end
end

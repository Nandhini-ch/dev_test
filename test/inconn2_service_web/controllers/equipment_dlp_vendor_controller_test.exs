defmodule Inconn2ServiceWeb.EquipmentDlpVendorControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentDlpVendor

  @create_attrs %{
    dlp_from: ~D[2010-04-17],
    dlp_to: ~D[2010-04-17],
    is_asset_under_dlp: true,
    service_branch_id: 42,
    vendor_id: 42,
    vendor_scope: "some vendor_scope"
  }
  @update_attrs %{
    dlp_from: ~D[2011-05-18],
    dlp_to: ~D[2011-05-18],
    is_asset_under_dlp: false,
    service_branch_id: 43,
    vendor_id: 43,
    vendor_scope: "some updated vendor_scope"
  }
  @invalid_attrs %{dlp_from: nil, dlp_to: nil, is_asset_under_dlp: nil, service_branch_id: nil, vendor_id: nil, vendor_scope: nil}

  def fixture(:equipment_dlp_vendor) do
    {:ok, equipment_dlp_vendor} = AssetInfo.create_equipment_dlp_vendor(@create_attrs)
    equipment_dlp_vendor
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all equipment_dlp_vendors", %{conn: conn} do
      conn = get(conn, Routes.equipment_dlp_vendor_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create equipment_dlp_vendor" do
    test "renders equipment_dlp_vendor when data is valid", %{conn: conn} do
      conn = post(conn, Routes.equipment_dlp_vendor_path(conn, :create), equipment_dlp_vendor: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.equipment_dlp_vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "dlp_from" => "2010-04-17",
               "dlp_to" => "2010-04-17",
               "is_asset_under_dlp" => true,
               "service_branch_id" => 42,
               "vendor_id" => 42,
               "vendor_scope" => "some vendor_scope"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.equipment_dlp_vendor_path(conn, :create), equipment_dlp_vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update equipment_dlp_vendor" do
    setup [:create_equipment_dlp_vendor]

    test "renders equipment_dlp_vendor when data is valid", %{conn: conn, equipment_dlp_vendor: %EquipmentDlpVendor{id: id} = equipment_dlp_vendor} do
      conn = put(conn, Routes.equipment_dlp_vendor_path(conn, :update, equipment_dlp_vendor), equipment_dlp_vendor: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.equipment_dlp_vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "dlp_from" => "2011-05-18",
               "dlp_to" => "2011-05-18",
               "is_asset_under_dlp" => false,
               "service_branch_id" => 43,
               "vendor_id" => 43,
               "vendor_scope" => "some updated vendor_scope"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, equipment_dlp_vendor: equipment_dlp_vendor} do
      conn = put(conn, Routes.equipment_dlp_vendor_path(conn, :update, equipment_dlp_vendor), equipment_dlp_vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete equipment_dlp_vendor" do
    setup [:create_equipment_dlp_vendor]

    test "deletes chosen equipment_dlp_vendor", %{conn: conn, equipment_dlp_vendor: equipment_dlp_vendor} do
      conn = delete(conn, Routes.equipment_dlp_vendor_path(conn, :delete, equipment_dlp_vendor))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.equipment_dlp_vendor_path(conn, :show, equipment_dlp_vendor))
      end
    end
  end

  defp create_equipment_dlp_vendor(_) do
    equipment_dlp_vendor = fixture(:equipment_dlp_vendor)
    %{equipment_dlp_vendor: equipment_dlp_vendor}
  end
end

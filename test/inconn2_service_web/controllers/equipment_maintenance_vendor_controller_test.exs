defmodule Inconn2ServiceWeb.EquipmentMaintenanceVendorControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentMaintenanceVendor

  @create_attrs %{
    amc_frequency: 42,
    amc_from: ~D[2010-04-17],
    amc_to: ~D[2010-04-17],
    is_asset_under_amc: true,
    response_time_in_minutes: 42,
    service_branch_id: 42,
    vendor_id: 42,
    vendor_scope: "some vendor_scope"
  }
  @update_attrs %{
    amc_frequency: 43,
    amc_from: ~D[2011-05-18],
    amc_to: ~D[2011-05-18],
    is_asset_under_amc: false,
    response_time_in_minutes: 43,
    service_branch_id: 43,
    vendor_id: 43,
    vendor_scope: "some updated vendor_scope"
  }
  @invalid_attrs %{amc_frequency: nil, amc_from: nil, amc_to: nil, is_asset_under_amc: nil, response_time_in_minutes: nil, service_branch_id: nil, vendor_id: nil, vendor_scope: nil}

  def fixture(:equipment_maintenance_vendor) do
    {:ok, equipment_maintenance_vendor} = AssetInfo.create_equipment_maintenance_vendor(@create_attrs)
    equipment_maintenance_vendor
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all equipment_maintenance_vendors", %{conn: conn} do
      conn = get(conn, Routes.equipment_maintenance_vendor_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create equipment_maintenance_vendor" do
    test "renders equipment_maintenance_vendor when data is valid", %{conn: conn} do
      conn = post(conn, Routes.equipment_maintenance_vendor_path(conn, :create), equipment_maintenance_vendor: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.equipment_maintenance_vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "amc_frequency" => 42,
               "amc_from" => "2010-04-17",
               "amc_to" => "2010-04-17",
               "is_asset_under_amc" => true,
               "response_time_in_minutes" => 42,
               "service_branch_id" => 42,
               "vendor_id" => 42,
               "vendor_scope" => "some vendor_scope"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.equipment_maintenance_vendor_path(conn, :create), equipment_maintenance_vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update equipment_maintenance_vendor" do
    setup [:create_equipment_maintenance_vendor]

    test "renders equipment_maintenance_vendor when data is valid", %{conn: conn, equipment_maintenance_vendor: %EquipmentMaintenanceVendor{id: id} = equipment_maintenance_vendor} do
      conn = put(conn, Routes.equipment_maintenance_vendor_path(conn, :update, equipment_maintenance_vendor), equipment_maintenance_vendor: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.equipment_maintenance_vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "amc_frequency" => 43,
               "amc_from" => "2011-05-18",
               "amc_to" => "2011-05-18",
               "is_asset_under_amc" => false,
               "response_time_in_minutes" => 43,
               "service_branch_id" => 43,
               "vendor_id" => 43,
               "vendor_scope" => "some updated vendor_scope"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, equipment_maintenance_vendor: equipment_maintenance_vendor} do
      conn = put(conn, Routes.equipment_maintenance_vendor_path(conn, :update, equipment_maintenance_vendor), equipment_maintenance_vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete equipment_maintenance_vendor" do
    setup [:create_equipment_maintenance_vendor]

    test "deletes chosen equipment_maintenance_vendor", %{conn: conn, equipment_maintenance_vendor: equipment_maintenance_vendor} do
      conn = delete(conn, Routes.equipment_maintenance_vendor_path(conn, :delete, equipment_maintenance_vendor))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.equipment_maintenance_vendor_path(conn, :show, equipment_maintenance_vendor))
      end
    end
  end

  defp create_equipment_maintenance_vendor(_) do
    equipment_maintenance_vendor = fixture(:equipment_maintenance_vendor)
    %{equipment_maintenance_vendor: equipment_maintenance_vendor}
  end
end

defmodule Inconn2ServiceWeb.EquipmentInsuranceVendorControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentInsuranceVendor

  @create_attrs %{
    end_date: ~D[2010-04-17],
    insurance_policy_no: "some insurance_policy_no",
    insurance_scope: "some insurance_scope",
    service_branch_id: 42,
    start_date: ~D[2010-04-17],
    vendor_id: 42
  }
  @update_attrs %{
    end_date: ~D[2011-05-18],
    insurance_policy_no: "some updated insurance_policy_no",
    insurance_scope: "some updated insurance_scope",
    service_branch_id: 43,
    start_date: ~D[2011-05-18],
    vendor_id: 43
  }
  @invalid_attrs %{end_date: nil, insurance_policy_no: nil, insurance_scope: nil, service_branch_id: nil, start_date: nil, vendor_id: nil}

  def fixture(:equipment_insurance_vendor) do
    {:ok, equipment_insurance_vendor} = AssetInfo.create_equipment_insurance_vendor(@create_attrs)
    equipment_insurance_vendor
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all equipment_insurance_vendors", %{conn: conn} do
      conn = get(conn, Routes.equipment_insurance_vendor_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create equipment_insurance_vendor" do
    test "renders equipment_insurance_vendor when data is valid", %{conn: conn} do
      conn = post(conn, Routes.equipment_insurance_vendor_path(conn, :create), equipment_insurance_vendor: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.equipment_insurance_vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2010-04-17",
               "insurance_policy_no" => "some insurance_policy_no",
               "insurance_scope" => "some insurance_scope",
               "service_branch_id" => 42,
               "start_date" => "2010-04-17",
               "vendor_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.equipment_insurance_vendor_path(conn, :create), equipment_insurance_vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update equipment_insurance_vendor" do
    setup [:create_equipment_insurance_vendor]

    test "renders equipment_insurance_vendor when data is valid", %{conn: conn, equipment_insurance_vendor: %EquipmentInsuranceVendor{id: id} = equipment_insurance_vendor} do
      conn = put(conn, Routes.equipment_insurance_vendor_path(conn, :update, equipment_insurance_vendor), equipment_insurance_vendor: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.equipment_insurance_vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2011-05-18",
               "insurance_policy_no" => "some updated insurance_policy_no",
               "insurance_scope" => "some updated insurance_scope",
               "service_branch_id" => 43,
               "start_date" => "2011-05-18",
               "vendor_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, equipment_insurance_vendor: equipment_insurance_vendor} do
      conn = put(conn, Routes.equipment_insurance_vendor_path(conn, :update, equipment_insurance_vendor), equipment_insurance_vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete equipment_insurance_vendor" do
    setup [:create_equipment_insurance_vendor]

    test "deletes chosen equipment_insurance_vendor", %{conn: conn, equipment_insurance_vendor: equipment_insurance_vendor} do
      conn = delete(conn, Routes.equipment_insurance_vendor_path(conn, :delete, equipment_insurance_vendor))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.equipment_insurance_vendor_path(conn, :show, equipment_insurance_vendor))
      end
    end
  end

  defp create_equipment_insurance_vendor(_) do
    equipment_insurance_vendor = fixture(:equipment_insurance_vendor)
    %{equipment_insurance_vendor: equipment_insurance_vendor}
  end
end

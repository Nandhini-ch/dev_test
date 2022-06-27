defmodule Inconn2ServiceWeb.InventorySupplierControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.InventorySupplier

  @create_attrs %{
    business_type: "some business_type",
    contact_no: "some contact_no",
    contact_person: "some contact_person",
    description: "some description",
    escalation1_contact_name: "some escalation1_contact_name",
    escalation1_contact_no: "some escalation1_contact_no",
    escalation2_contact_name: "some escalation2_contact_name",
    escalation2_contact_no: "some escalation2_contact_no",
    gst_no: "some gst_no",
    name: "some name",
    reference_no: "some reference_no",
    website: "some website"
  }
  @update_attrs %{
    business_type: "some updated business_type",
    contact_no: "some updated contact_no",
    contact_person: "some updated contact_person",
    description: "some updated description",
    escalation1_contact_name: "some updated escalation1_contact_name",
    escalation1_contact_no: "some updated escalation1_contact_no",
    escalation2_contact_name: "some updated escalation2_contact_name",
    escalation2_contact_no: "some updated escalation2_contact_no",
    gst_no: "some updated gst_no",
    name: "some updated name",
    reference_no: "some updated reference_no",
    website: "some updated website"
  }
  @invalid_attrs %{business_type: nil, contact_no: nil, contact_person: nil, description: nil, escalation1_contact_name: nil, escalation1_contact_no: nil, escalation2_contact_name: nil, escalation2_contact_no: nil, gst_no: nil, name: nil, reference_no: nil, website: nil}

  def fixture(:inventory_supplier) do
    {:ok, inventory_supplier} = InventoryManagement.create_inventory_supplier(@create_attrs)
    inventory_supplier
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventory_suppliers", %{conn: conn} do
      conn = get(conn, Routes.inventory_supplier_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory_supplier" do
    test "renders inventory_supplier when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_supplier_path(conn, :create), inventory_supplier: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_supplier_path(conn, :show, id))

      assert %{
               "id" => id,
               "business_type" => "some business_type",
               "contact_no" => "some contact_no",
               "contact_person" => "some contact_person",
               "description" => "some description",
               "escalation1_contact_name" => "some escalation1_contact_name",
               "escalation1_contact_no" => "some escalation1_contact_no",
               "escalation2_contact_name" => "some escalation2_contact_name",
               "escalation2_contact_no" => "some escalation2_contact_no",
               "gst_no" => "some gst_no",
               "name" => "some name",
               "reference_no" => "some reference_no",
               "website" => "some website"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_supplier_path(conn, :create), inventory_supplier: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory_supplier" do
    setup [:create_inventory_supplier]

    test "renders inventory_supplier when data is valid", %{conn: conn, inventory_supplier: %InventorySupplier{id: id} = inventory_supplier} do
      conn = put(conn, Routes.inventory_supplier_path(conn, :update, inventory_supplier), inventory_supplier: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_supplier_path(conn, :show, id))

      assert %{
               "id" => id,
               "business_type" => "some updated business_type",
               "contact_no" => "some updated contact_no",
               "contact_person" => "some updated contact_person",
               "description" => "some updated description",
               "escalation1_contact_name" => "some updated escalation1_contact_name",
               "escalation1_contact_no" => "some updated escalation1_contact_no",
               "escalation2_contact_name" => "some updated escalation2_contact_name",
               "escalation2_contact_no" => "some updated escalation2_contact_no",
               "gst_no" => "some updated gst_no",
               "name" => "some updated name",
               "reference_no" => "some updated reference_no",
               "website" => "some updated website"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory_supplier: inventory_supplier} do
      conn = put(conn, Routes.inventory_supplier_path(conn, :update, inventory_supplier), inventory_supplier: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory_supplier" do
    setup [:create_inventory_supplier]

    test "deletes chosen inventory_supplier", %{conn: conn, inventory_supplier: inventory_supplier} do
      conn = delete(conn, Routes.inventory_supplier_path(conn, :delete, inventory_supplier))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_supplier_path(conn, :show, inventory_supplier))
      end
    end
  end

  defp create_inventory_supplier(_) do
    inventory_supplier = fixture(:inventory_supplier)
    %{inventory_supplier: inventory_supplier}
  end
end

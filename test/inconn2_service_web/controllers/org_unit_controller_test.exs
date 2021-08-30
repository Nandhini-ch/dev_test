defmodule Inconn2ServiceWeb.OrgUnitControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.OrgUnit

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:org_unit) do
    {:ok, org_unit} = Staff.create_org_unit(@create_attrs)
    org_unit
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all org_units", %{conn: conn} do
      conn = get(conn, Routes.org_unit_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create org_unit" do
    test "renders org_unit when data is valid", %{conn: conn} do
      conn = post(conn, Routes.org_unit_path(conn, :create), org_unit: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.org_unit_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.org_unit_path(conn, :create), org_unit: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update org_unit" do
    setup [:create_org_unit]

    test "renders org_unit when data is valid", %{conn: conn, org_unit: %OrgUnit{id: id} = org_unit} do
      conn = put(conn, Routes.org_unit_path(conn, :update, org_unit), org_unit: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.org_unit_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, org_unit: org_unit} do
      conn = put(conn, Routes.org_unit_path(conn, :update, org_unit), org_unit: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete org_unit" do
    setup [:create_org_unit]

    test "deletes chosen org_unit", %{conn: conn, org_unit: org_unit} do
      conn = delete(conn, Routes.org_unit_path(conn, :delete, org_unit))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.org_unit_path(conn, :show, org_unit))
      end
    end
  end

  defp create_org_unit(_) do
    org_unit = fixture(:org_unit)
    %{org_unit: org_unit}
  end
end

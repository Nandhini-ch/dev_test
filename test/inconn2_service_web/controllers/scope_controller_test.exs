defmodule Inconn2ServiceWeb.ScopeControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.Scope

  @create_attrs %{
    applicable_to_all_asset_category: true,
    applicable_to_all_location: true,
    asset_category_ids: [],
    location_ids: []
  }
  @update_attrs %{
    applicable_to_all_asset_category: false,
    applicable_to_all_location: false,
    asset_category_ids: [],
    location_ids: []
  }
  @invalid_attrs %{applicable_to_all_asset_category: nil, applicable_to_all_location: nil, asset_category_ids: nil, location_ids: nil}

  def fixture(:scope) do
    {:ok, scope} = ContractManagement.create_scope(@create_attrs)
    scope
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all scopes", %{conn: conn} do
      conn = get(conn, Routes.scope_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create scope" do
    test "renders scope when data is valid", %{conn: conn} do
      conn = post(conn, Routes.scope_path(conn, :create), scope: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.scope_path(conn, :show, id))

      assert %{
               "id" => id,
               "applicable_to_all_asset_category" => true,
               "applicable_to_all_location" => true,
               "asset_category_ids" => [],
               "location_ids" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.scope_path(conn, :create), scope: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update scope" do
    setup [:create_scope]

    test "renders scope when data is valid", %{conn: conn, scope: %Scope{id: id} = scope} do
      conn = put(conn, Routes.scope_path(conn, :update, scope), scope: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.scope_path(conn, :show, id))

      assert %{
               "id" => id,
               "applicable_to_all_asset_category" => false,
               "applicable_to_all_location" => false,
               "asset_category_ids" => [],
               "location_ids" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, scope: scope} do
      conn = put(conn, Routes.scope_path(conn, :update, scope), scope: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete scope" do
    setup [:create_scope]

    test "deletes chosen scope", %{conn: conn, scope: scope} do
      conn = delete(conn, Routes.scope_path(conn, :delete, scope))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.scope_path(conn, :show, scope))
      end
    end
  end

  defp create_scope(_) do
    scope = fixture(:scope)
    %{scope: scope}
  end
end

defmodule Inconn2ServiceWeb.UomCategoryControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.UomCategory

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:uom_category) do
    {:ok, uom_category} = InventoryManagement.create_uom_category(@create_attrs)
    uom_category
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all uom_categories", %{conn: conn} do
      conn = get(conn, Routes.uom_category_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create uom_category" do
    test "renders uom_category when data is valid", %{conn: conn} do
      conn = post(conn, Routes.uom_category_path(conn, :create), uom_category: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.uom_category_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.uom_category_path(conn, :create), uom_category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update uom_category" do
    setup [:create_uom_category]

    test "renders uom_category when data is valid", %{conn: conn, uom_category: %UomCategory{id: id} = uom_category} do
      conn = put(conn, Routes.uom_category_path(conn, :update, uom_category), uom_category: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.uom_category_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, uom_category: uom_category} do
      conn = put(conn, Routes.uom_category_path(conn, :update, uom_category), uom_category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete uom_category" do
    setup [:create_uom_category]

    test "deletes chosen uom_category", %{conn: conn, uom_category: uom_category} do
      conn = delete(conn, Routes.uom_category_path(conn, :delete, uom_category))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.uom_category_path(conn, :show, uom_category))
      end
    end
  end

  defp create_uom_category(_) do
    uom_category = fixture(:uom_category)
    %{uom_category: uom_category}
  end
end

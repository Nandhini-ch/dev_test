defmodule Inconn2ServiceWeb.PublicUomControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Common
  alias Inconn2Service.Common.PublicUom

  @create_attrs %{
    description: "some description",
    uom_category: "some uom_category",
    uom_unit: "some uom_unit"
  }
  @update_attrs %{
    description: "some updated description",
    uom_category: "some updated uom_category",
    uom_unit: "some updated uom_unit"
  }
  @invalid_attrs %{description: nil, uom_category: nil, uom_unit: nil}

  def fixture(:public_uom) do
    {:ok, public_uom} = Common.create_public_uom(@create_attrs)
    public_uom
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all public_uoms", %{conn: conn} do
      conn = get(conn, Routes.public_uom_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create public_uom" do
    test "renders public_uom when data is valid", %{conn: conn} do
      conn = post(conn, Routes.public_uom_path(conn, :create), public_uom: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.public_uom_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "uom_category" => "some uom_category",
               "uom_unit" => "some uom_unit"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.public_uom_path(conn, :create), public_uom: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update public_uom" do
    setup [:create_public_uom]

    test "renders public_uom when data is valid", %{conn: conn, public_uom: %PublicUom{id: id} = public_uom} do
      conn = put(conn, Routes.public_uom_path(conn, :update, public_uom), public_uom: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.public_uom_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "uom_category" => "some updated uom_category",
               "uom_unit" => "some updated uom_unit"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, public_uom: public_uom} do
      conn = put(conn, Routes.public_uom_path(conn, :update, public_uom), public_uom: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete public_uom" do
    setup [:create_public_uom]

    test "deletes chosen public_uom", %{conn: conn, public_uom: public_uom} do
      conn = delete(conn, Routes.public_uom_path(conn, :delete, public_uom))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.public_uom_path(conn, :show, public_uom))
      end
    end
  end

  defp create_public_uom(_) do
    public_uom = fixture(:public_uom)
    %{public_uom: public_uom}
  end
end

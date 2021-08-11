defmodule Inconn2ServiceWeb.BusinessTypeControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Account
  alias Inconn2Service.Account.BusinessType

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:business_type) do
    {:ok, business_type} = Account.create_business_type(@create_attrs)
    business_type
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all business_types", %{conn: conn} do
      conn = get(conn, Routes.business_type_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create business_type" do
    test "renders business_type when data is valid", %{conn: conn} do
      conn = post(conn, Routes.business_type_path(conn, :create), business_type: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.business_type_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.business_type_path(conn, :create), business_type: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update business_type" do
    setup [:create_business_type]

    test "renders business_type when data is valid", %{conn: conn, business_type: %BusinessType{id: id} = business_type} do
      conn = put(conn, Routes.business_type_path(conn, :update, business_type), business_type: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.business_type_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, business_type: business_type} do
      conn = put(conn, Routes.business_type_path(conn, :update, business_type), business_type: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete business_type" do
    setup [:create_business_type]

    test "deletes chosen business_type", %{conn: conn, business_type: business_type} do
      conn = delete(conn, Routes.business_type_path(conn, :delete, business_type))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.business_type_path(conn, :show, business_type))
      end
    end
  end

  defp create_business_type(_) do
    business_type = fixture(:business_type)
    %{business_type: business_type}
  end
end

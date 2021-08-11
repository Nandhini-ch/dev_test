defmodule Inconn2ServiceWeb.LicenseeControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Account
  alias Inconn2Service.Account.Licensee

  @create_attrs %{
    address: %{},
    business_types: "some business_types",
    company_name: "some company_name",
    contact: %{}
  }
  @update_attrs %{
    address: %{},
    business_types: "some updated business_types",
    company_name: "some updated company_name",
    contact: %{}
  }
  @invalid_attrs %{address: nil, business_types: nil, company_name: nil, contact: nil}

  def fixture(:licensee) do
    {:ok, licensee} = Account.create_licensee(@create_attrs)
    licensee
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all licensees", %{conn: conn} do
      conn = get(conn, Routes.licensee_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create licensee" do
    test "renders licensee when data is valid", %{conn: conn} do
      conn = post(conn, Routes.licensee_path(conn, :create), licensee: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.licensee_path(conn, :show, id))

      assert %{
               "id" => id,
               "address" => %{},
               "business_types" => "some business_types",
               "company_name" => "some company_name",
               "contact" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.licensee_path(conn, :create), licensee: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update licensee" do
    setup [:create_licensee]

    test "renders licensee when data is valid", %{conn: conn, licensee: %Licensee{id: id} = licensee} do
      conn = put(conn, Routes.licensee_path(conn, :update, licensee), licensee: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.licensee_path(conn, :show, id))

      assert %{
               "id" => id,
               "address" => %{},
               "business_types" => "some updated business_types",
               "company_name" => "some updated company_name",
               "contact" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, licensee: licensee} do
      conn = put(conn, Routes.licensee_path(conn, :update, licensee), licensee: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete licensee" do
    setup [:create_licensee]

    test "deletes chosen licensee", %{conn: conn, licensee: licensee} do
      conn = delete(conn, Routes.licensee_path(conn, :delete, licensee))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.licensee_path(conn, :show, licensee))
      end
    end
  end

  defp create_licensee(_) do
    licensee = fixture(:licensee)
    %{licensee: licensee}
  end
end

defmodule Inconn2ServiceWeb.AdminUserControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Common
  alias Inconn2Service.Common.AdminUser

  @create_attrs %{
    email: "some email",
    full_name: "some full_name",
    password: "some password",
    phone_no: "some phone_no"
  }
  @update_attrs %{
    email: "some updated email",
    full_name: "some updated full_name",
    password: "some updated password",
    phone_no: "some updated phone_no"
  }
  @invalid_attrs %{email: nil, full_name: nil, password: nil, phone_no: nil}

  def fixture(:admin_user) do
    {:ok, admin_user} = Common.create_admin_user(@create_attrs)
    admin_user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all admin_user", %{conn: conn} do
      conn = get(conn, Routes.admin_user_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create admin_user" do
    test "renders admin_user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.admin_user_path(conn, :create), admin_user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.admin_user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some email",
               "full_name" => "some full_name",
               "password" => "some password",
               "phone_no" => "some phone_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_user_path(conn, :create), admin_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update admin_user" do
    setup [:create_admin_user]

    test "renders admin_user when data is valid", %{conn: conn, admin_user: %AdminUser{id: id} = admin_user} do
      conn = put(conn, Routes.admin_user_path(conn, :update, admin_user), admin_user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.admin_user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some updated email",
               "full_name" => "some updated full_name",
               "password" => "some updated password",
               "phone_no" => "some updated phone_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, admin_user: admin_user} do
      conn = put(conn, Routes.admin_user_path(conn, :update, admin_user), admin_user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete admin_user" do
    setup [:create_admin_user]

    test "deletes chosen admin_user", %{conn: conn, admin_user: admin_user} do
      conn = delete(conn, Routes.admin_user_path(conn, :delete, admin_user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.admin_user_path(conn, :show, admin_user))
      end
    end
  end

  defp create_admin_user(_) do
    admin_user = fixture(:admin_user)
    %{admin_user: admin_user}
  end
end

defmodule Inconn2ServiceWeb.RoleProfileControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.RoleProfile

  @create_attrs %{
    code: "some code",
    feature_ids: [],
    label: "some label"
  }
  @update_attrs %{
    code: "some updated code",
    feature_ids: [],
    label: "some updated label"
  }
  @invalid_attrs %{code: nil, feature_ids: nil, label: nil}

  def fixture(:role_profile) do
    {:ok, role_profile} = Staff.create_role_profile(@create_attrs)
    role_profile
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all role_profiles", %{conn: conn} do
      conn = get(conn, Routes.role_profile_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create role_profile" do
    test "renders role_profile when data is valid", %{conn: conn} do
      conn = post(conn, Routes.role_profile_path(conn, :create), role_profile: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.role_profile_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some code",
               "feature_ids" => [],
               "label" => "some label"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.role_profile_path(conn, :create), role_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update role_profile" do
    setup [:create_role_profile]

    test "renders role_profile when data is valid", %{conn: conn, role_profile: %RoleProfile{id: id} = role_profile} do
      conn = put(conn, Routes.role_profile_path(conn, :update, role_profile), role_profile: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.role_profile_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some updated code",
               "feature_ids" => [],
               "label" => "some updated label"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, role_profile: role_profile} do
      conn = put(conn, Routes.role_profile_path(conn, :update, role_profile), role_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete role_profile" do
    setup [:create_role_profile]

    test "deletes chosen role_profile", %{conn: conn, role_profile: role_profile} do
      conn = delete(conn, Routes.role_profile_path(conn, :delete, role_profile))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.role_profile_path(conn, :show, role_profile))
      end
    end
  end

  defp create_role_profile(_) do
    role_profile = fixture(:role_profile)
    %{role_profile: role_profile}
  end
end

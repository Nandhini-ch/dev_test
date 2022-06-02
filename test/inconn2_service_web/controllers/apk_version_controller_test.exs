defmodule Inconn2ServiceWeb.Apk_versionControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AppSettings
  alias Inconn2Service.AppSettings.Apk_version

  @create_attrs %{
    version_no: "some version_no"
  }
  @update_attrs %{
    version_no: "some updated version_no"
  }
  @invalid_attrs %{version_no: nil}

  def fixture(:apk_version) do
    {:ok, apk_version} = AppSettings.create_apk_version(@create_attrs)
    apk_version
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all apk_versions", %{conn: conn} do
      conn = get(conn, Routes.apk_version_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create apk_version" do
    test "renders apk_version when data is valid", %{conn: conn} do
      conn = post(conn, Routes.apk_version_path(conn, :create), apk_version: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.apk_version_path(conn, :show, id))

      assert %{
               "id" => id,
               "version_no" => "some version_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.apk_version_path(conn, :create), apk_version: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update apk_version" do
    setup [:create_apk_version]

    test "renders apk_version when data is valid", %{conn: conn, apk_version: %Apk_version{id: id} = apk_version} do
      conn = put(conn, Routes.apk_version_path(conn, :update, apk_version), apk_version: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.apk_version_path(conn, :show, id))

      assert %{
               "id" => id,
               "version_no" => "some updated version_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, apk_version: apk_version} do
      conn = put(conn, Routes.apk_version_path(conn, :update, apk_version), apk_version: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete apk_version" do
    setup [:create_apk_version]

    test "deletes chosen apk_version", %{conn: conn, apk_version: apk_version} do
      conn = delete(conn, Routes.apk_version_path(conn, :delete, apk_version))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.apk_version_path(conn, :show, apk_version))
      end
    end
  end

  defp create_apk_version(_) do
    apk_version = fixture(:apk_version)
    %{apk_version: apk_version}
  end
end

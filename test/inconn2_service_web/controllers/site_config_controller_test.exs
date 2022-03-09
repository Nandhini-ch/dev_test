defmodule Inconn2ServiceWeb.SiteConfigControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.SiteConfig

  @create_attrs %{
    config: %{}
  }
  @update_attrs %{
    config: %{}
  }
  @invalid_attrs %{config: nil}

  def fixture(:site_config) do
    {:ok, site_config} = AssetConfig.create_site_config(@create_attrs)
    site_config
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all site_config", %{conn: conn} do
      conn = get(conn, Routes.site_config_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create site_config" do
    test "renders site_config when data is valid", %{conn: conn} do
      conn = post(conn, Routes.site_config_path(conn, :create), site_config: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.site_config_path(conn, :show, id))

      assert %{
               "id" => id,
               "config" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.site_config_path(conn, :create), site_config: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update site_config" do
    setup [:create_site_config]

    test "renders site_config when data is valid", %{conn: conn, site_config: %SiteConfig{id: id} = site_config} do
      conn = put(conn, Routes.site_config_path(conn, :update, site_config), site_config: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.site_config_path(conn, :show, id))

      assert %{
               "id" => id,
               "config" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, site_config: site_config} do
      conn = put(conn, Routes.site_config_path(conn, :update, site_config), site_config: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete site_config" do
    setup [:create_site_config]

    test "deletes chosen site_config", %{conn: conn, site_config: site_config} do
      conn = delete(conn, Routes.site_config_path(conn, :delete, site_config))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.site_config_path(conn, :show, site_config))
      end
    end
  end

  defp create_site_config(_) do
    site_config = fixture(:site_config)
    %{site_config: site_config}
  end
end

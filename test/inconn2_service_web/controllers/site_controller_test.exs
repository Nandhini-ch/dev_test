defmodule Inconn2ServiceWeb.SiteControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetManagement
  alias Inconn2Service.AssetManagement.Site

  @create_attrs %{
    area: 120.5,
    branch: "some branch",
    description: "some description",
    lattitude: 120.5,
    longitiude: 120.5,
    name: "some name",
    radius: 120.5
  }
  @update_attrs %{
    area: 456.7,
    branch: "some updated branch",
    description: "some updated description",
    lattitude: 456.7,
    longitiude: 456.7,
    name: "some updated name",
    radius: 456.7
  }
  @invalid_attrs %{area: nil, branch: nil, description: nil, lattitude: nil, longitiude: nil, name: nil, radius: nil}

  def fixture(:site) do
    {:ok, site} = AssetManagement.create_site(@create_attrs)
    site
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all sites", %{conn: conn} do
      conn = get(conn, Routes.site_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create site" do
    test "renders site when data is valid", %{conn: conn} do
      conn = post(conn, Routes.site_path(conn, :create), site: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.site_path(conn, :show, id))

      assert %{
               "id" => id,
               "area" => 120.5,
               "branch" => "some branch",
               "description" => "some description",
               "lattitude" => 120.5,
               "longitiude" => 120.5,
               "name" => "some name",
               "radius" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.site_path(conn, :create), site: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update site" do
    setup [:create_site]

    test "renders site when data is valid", %{conn: conn, site: %Site{id: id} = site} do
      conn = put(conn, Routes.site_path(conn, :update, site), site: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.site_path(conn, :show, id))

      assert %{
               "id" => id,
               "area" => 456.7,
               "branch" => "some updated branch",
               "description" => "some updated description",
               "lattitude" => 456.7,
               "longitiude" => 456.7,
               "name" => "some updated name",
               "radius" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, site: site} do
      conn = put(conn, Routes.site_path(conn, :update, site), site: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete site" do
    setup [:create_site]

    test "deletes chosen site", %{conn: conn, site: site} do
      conn = delete(conn, Routes.site_path(conn, :delete, site))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.site_path(conn, :show, site))
      end
    end
  end

  defp create_site(_) do
    site = fixture(:site)
    %{site: site}
  end
end

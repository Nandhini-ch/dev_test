defmodule Inconn2Service.AssetManagementTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.AssetManagement

  describe "sites" do
    alias Inconn2Service.AssetManagement.Site

    @valid_attrs %{area: 120.5, branch: "some branch", description: "some description", lattitude: 120.5, longitiude: 120.5, name: "some name", radius: 120.5}
    @update_attrs %{area: 456.7, branch: "some updated branch", description: "some updated description", lattitude: 456.7, longitiude: 456.7, name: "some updated name", radius: 456.7}
    @invalid_attrs %{area: nil, branch: nil, description: nil, lattitude: nil, longitiude: nil, name: nil, radius: nil}

    def site_fixture(attrs \\ %{}) do
      {:ok, site} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetManagement.create_site()

      site
    end

    test "list_sites/0 returns all sites" do
      site = site_fixture()
      assert AssetManagement.list_sites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert AssetManagement.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      assert {:ok, %Site{} = site} = AssetManagement.create_site(@valid_attrs)
      assert site.area == 120.5
      assert site.branch == "some branch"
      assert site.description == "some description"
      assert site.lattitude == 120.5
      assert site.longitiude == 120.5
      assert site.name == "some name"
      assert site.radius == 120.5
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetManagement.create_site(@invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      assert {:ok, %Site{} = site} = AssetManagement.update_site(site, @update_attrs)
      assert site.area == 456.7
      assert site.branch == "some updated branch"
      assert site.description == "some updated description"
      assert site.lattitude == 456.7
      assert site.longitiude == 456.7
      assert site.name == "some updated name"
      assert site.radius == 456.7
    end

    test "update_site/2 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetManagement.update_site(site, @invalid_attrs)
      assert site == AssetManagement.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = AssetManagement.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> AssetManagement.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = AssetManagement.change_site(site)
    end
  end
end

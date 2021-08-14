defmodule Inconn2Service.AssetConfigTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.AssetConfig

  describe "sites" do
    alias Inconn2Service.AssetConfig.Site

    @valid_attrs %{
      area: 120.5,
      branch: "some branch",
      description: "some description",
      lattitude: 120.5,
      longitiude: 120.5,
      name: "some name",
      fencing_radius: 120.5
    }
    @update_attrs %{
      area: 456.7,
      branch: "some updated branch",
      description: "some updated description",
      lattitude: 456.7,
      longitiude: 456.7,
      name: "some updated name",
      fencing_radius: 456.7
    }
    @invalid_attrs %{
      area: nil,
      branch: nil,
      description: nil,
      lattitude: nil,
      longitiude: nil,
      name: nil,
      fencing_radius: nil
    }

    def site_fixture(attrs \\ %{}) do
      {:ok, site} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetConfig.create_site()

      site
    end

    test "list_sites/0 returns all sites" do
      site = site_fixture()
      assert AssetConfig.list_sites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert AssetConfig.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      assert {:ok, %Site{} = site} = AssetConfig.create_site(@valid_attrs)
      assert site.area == 120.5
      assert site.branch == "some branch"
      assert site.description == "some description"
      assert site.lattitude == 120.5
      assert site.longitiude == 120.5
      assert site.name == "some name"
      assert site.radius == 120.5
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetConfig.create_site(@invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      assert {:ok, %Site{} = site} = AssetConfig.update_site(site, @update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = AssetConfig.update_site(site, @invalid_attrs)
      assert site == AssetConfig.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = AssetConfig.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> AssetConfig.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = AssetConfig.change_site(site)
    end
  end

  describe "locations" do
    alias Inconn2Service.AssetConfig.Location

    @valid_attrs %{code: "some code", description: "some description", name: "some name"}
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      name: "some updated name"
    }
    @invalid_attrs %{code: nil, description: nil, name: nil}

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetConfig.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert AssetConfig.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert AssetConfig.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = AssetConfig.create_location(@valid_attrs)
      assert location.code == "some code"
      assert location.description == "some description"
      assert location.name == "some name"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetConfig.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, %Location{} = location} = AssetConfig.update_location(location, @update_attrs)
      assert location.code == "some updated code"
      assert location.description == "some updated description"
      assert location.name == "some updated name"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetConfig.update_location(location, @invalid_attrs)
      assert location == AssetConfig.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = AssetConfig.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> AssetConfig.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = AssetConfig.change_location(location)
    end
  end
end

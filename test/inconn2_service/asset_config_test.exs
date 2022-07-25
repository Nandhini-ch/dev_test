defmodule Inconn2Service.AssetConfigTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.AssetConfig

  describe "sites" do
    alias Inconn2Service.AssetConfig.Site

    @valid_attrs %{
      area: 120.5,
      branch: "some branch",
      description: "some description",
      latitude: 120.5,
      longitude: 120.5,
      name: "some name",
      fencing_radius: 120.5
    }
    @update_attrs %{
      area: 456.7,
      branch: "some updated branch",
      description: "some updated description",
      latitude: 456.7,
      longitude: 456.7,
      name: "some updated name",
      fencing_radius: 456.7
    }
    @invalid_attrs %{
      area: nil,
      branch: nil,
      description: nil,
      latitude: nil,
      longitude: nil,
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
      assert site.latitude == 120.5
      assert site.longitude == 120.5
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
      assert site.latitude == 456.7
      assert site.longitude == 456.7
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

  describe "parties" do
    alias Inconn2Service.AssetConfig.Party

    @valid_attrs %{contract_end_date: ~D[2010-04-17], contract_start_date: ~D[2010-04-17], license_no: "some license_no", licensee: "some licensee", org_name: "some org_name", party_type: [], preferred_service: "some preferred_service", rates_per_hour: 120.5, service_id: "some service_id", service_type: "some service_type", type_of_maintenance: []}
    @update_attrs %{contract_end_date: ~D[2011-05-18], contract_start_date: ~D[2011-05-18], license_no: "some updated license_no", licensee: "some updated licensee", org_name: "some updated org_name", party_type: [], preferred_service: "some updated preferred_service", rates_per_hour: 456.7, service_id: "some updated service_id", service_type: "some updated service_type", type_of_maintenance: []}
    @invalid_attrs %{contract_end_date: nil, contract_start_date: nil, license_no: nil, licensee: nil, org_name: nil, party_type: nil, preferred_service: nil, rates_per_hour: nil, service_id: nil, service_type: nil, type_of_maintenance: nil}

    def party_fixture(attrs \\ %{}) do
      {:ok, party} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetConfig.create_party()

      party
    end

    test "list_parties/0 returns all parties" do
      party = party_fixture()
      assert AssetConfig.list_parties() == [party]
    end

    test "get_party!/1 returns the party with given id" do
      party = party_fixture()
      assert AssetConfig.get_party!(party.id) == party
    end

    test "create_party/1 with valid data creates a party" do
      assert {:ok, %Party{} = party} = AssetConfig.create_party(@valid_attrs)
      assert party.contract_end_date == ~D[2010-04-17]
      assert party.contract_start_date == ~D[2010-04-17]
      assert party.license_no == "some license_no"
      assert party.licensee == "some licensee"
      assert party.org_name == "some org_name"
      assert party.party_type == []
      assert party.preferred_service == "some preferred_service"
      assert party.rates_per_hour == 120.5
      assert party.service_id == "some service_id"
      assert party.service_type == "some service_type"
      assert party.type_of_maintenance == []
    end

    test "create_party/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetConfig.create_party(@invalid_attrs)
    end

    test "update_party/2 with valid data updates the party" do
      party = party_fixture()
      assert {:ok, %Party{} = party} = AssetConfig.update_party(party, @update_attrs)
      assert party.contract_end_date == ~D[2011-05-18]
      assert party.contract_start_date == ~D[2011-05-18]
      assert party.license_no == "some updated license_no"
      assert party.licensee == "some updated licensee"
      assert party.org_name == "some updated org_name"
      assert party.party_type == []
      assert party.preferred_service == "some updated preferred_service"
      assert party.rates_per_hour == 456.7
      assert party.service_id == "some updated service_id"
      assert party.service_type == "some updated service_type"
      assert party.type_of_maintenance == []
    end

    test "update_party/2 with invalid data returns error changeset" do
      party = party_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetConfig.update_party(party, @invalid_attrs)
      assert party == AssetConfig.get_party!(party.id)
    end

    test "delete_party/1 deletes the party" do
      party = party_fixture()
      assert {:ok, %Party{}} = AssetConfig.delete_party(party)
      assert_raise Ecto.NoResultsError, fn -> AssetConfig.get_party!(party.id) end
    end

    test "change_party/1 returns a party changeset" do
      party = party_fixture()
      assert %Ecto.Changeset{} = AssetConfig.change_party(party)
    end
  end

  describe "asset_status_tracks" do
    alias Inconn2Service.AssetConfig.AssetStatusTrack

    @valid_attrs %{asset_id: 42, asset_type: "some asset_type", changed_date_time: ~N[2010-04-17 14:00:00], status_changed: "some status_changed", user_id: 42}
    @update_attrs %{asset_id: 43, asset_type: "some updated asset_type", changed_date_time: ~N[2011-05-18 15:01:01], status_changed: "some updated status_changed", user_id: 43}
    @invalid_attrs %{asset_id: nil, asset_type: nil, changed_date_time: nil, status_changed: nil, user_id: nil}

    def asset_status_track_fixture(attrs \\ %{}) do
      {:ok, asset_status_track} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetConfig.create_asset_status_track()

      asset_status_track
    end

    test "list_asset_status_tracks/0 returns all asset_status_tracks" do
      asset_status_track = asset_status_track_fixture()
      assert AssetConfig.list_asset_status_tracks() == [asset_status_track]
    end

    test "get_asset_status_track!/1 returns the asset_status_track with given id" do
      asset_status_track = asset_status_track_fixture()
      assert AssetConfig.get_asset_status_track!(asset_status_track.id) == asset_status_track
    end

    test "create_asset_status_track/1 with valid data creates a asset_status_track" do
      assert {:ok, %AssetStatusTrack{} = asset_status_track} = AssetConfig.create_asset_status_track(@valid_attrs)
      assert asset_status_track.asset_id == 42
      assert asset_status_track.asset_type == "some asset_type"
      assert asset_status_track.changed_date_time == ~N[2010-04-17 14:00:00]
      assert asset_status_track.status_changed == "some status_changed"
      assert asset_status_track.user_id == 42
    end

    test "create_asset_status_track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetConfig.create_asset_status_track(@invalid_attrs)
    end

    test "update_asset_status_track/2 with valid data updates the asset_status_track" do
      asset_status_track = asset_status_track_fixture()
      assert {:ok, %AssetStatusTrack{} = asset_status_track} = AssetConfig.update_asset_status_track(asset_status_track, @update_attrs)
      assert asset_status_track.asset_id == 43
      assert asset_status_track.asset_type == "some updated asset_type"
      assert asset_status_track.changed_date_time == ~N[2011-05-18 15:01:01]
      assert asset_status_track.status_changed == "some updated status_changed"
      assert asset_status_track.user_id == 43
    end

    test "update_asset_status_track/2 with invalid data returns error changeset" do
      asset_status_track = asset_status_track_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetConfig.update_asset_status_track(asset_status_track, @invalid_attrs)
      assert asset_status_track == AssetConfig.get_asset_status_track!(asset_status_track.id)
    end

    test "delete_asset_status_track/1 deletes the asset_status_track" do
      asset_status_track = asset_status_track_fixture()
      assert {:ok, %AssetStatusTrack{}} = AssetConfig.delete_asset_status_track(asset_status_track)
      assert_raise Ecto.NoResultsError, fn -> AssetConfig.get_asset_status_track!(asset_status_track.id) end
    end

    test "change_asset_status_track/1 returns a asset_status_track changeset" do
      asset_status_track = asset_status_track_fixture()
      assert %Ecto.Changeset{} = AssetConfig.change_asset_status_track(asset_status_track)
    end
  end

  describe "site_config" do
    alias Inconn2Service.AssetConfig.SiteConfig

    @valid_attrs %{config: %{}}
    @update_attrs %{config: %{}}
    @invalid_attrs %{config: nil}

    def site_config_fixture(attrs \\ %{}) do
      {:ok, site_config} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetConfig.create_site_config()

      site_config
    end

    test "list_site_config/0 returns all site_config" do
      site_config = site_config_fixture()
      assert AssetConfig.list_site_config() == [site_config]
    end

    test "get_site_config!/1 returns the site_config with given id" do
      site_config = site_config_fixture()
      assert AssetConfig.get_site_config!(site_config.id) == site_config
    end

    test "create_site_config/1 with valid data creates a site_config" do
      assert {:ok, %SiteConfig{} = site_config} = AssetConfig.create_site_config(@valid_attrs)
      assert site_config.config == %{}
    end

    test "create_site_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetConfig.create_site_config(@invalid_attrs)
    end

    test "update_site_config/2 with valid data updates the site_config" do
      site_config = site_config_fixture()
      assert {:ok, %SiteConfig{} = site_config} = AssetConfig.update_site_config(site_config, @update_attrs)
      assert site_config.config == %{}
    end

    test "update_site_config/2 with invalid data returns error changeset" do
      site_config = site_config_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetConfig.update_site_config(site_config, @invalid_attrs)
      assert site_config == AssetConfig.get_site_config!(site_config.id)
    end

    test "delete_site_config/1 deletes the site_config" do
      site_config = site_config_fixture()
      assert {:ok, %SiteConfig{}} = AssetConfig.delete_site_config(site_config)
      assert_raise Ecto.NoResultsError, fn -> AssetConfig.get_site_config!(site_config.id) end
    end

    test "change_site_config/1 returns a site_config changeset" do
      site_config = site_config_fixture()
      assert %Ecto.Changeset{} = AssetConfig.change_site_config(site_config)
    end
  end

  describe "zones" do
    alias Inconn2Service.AssetConfig.Zone

    @valid_attrs %{description: "some description", name: "some name", path: []}
    @update_attrs %{description: "some updated description", name: "some updated name", path: []}
    @invalid_attrs %{description: nil, name: nil, path: nil}

    def zone_fixture(attrs \\ %{}) do
      {:ok, zone} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetConfig.create_zone()

      zone
    end

    test "list_zones/0 returns all zones" do
      zone = zone_fixture()
      assert AssetConfig.list_zones() == [zone]
    end

    test "get_zone!/1 returns the zone with given id" do
      zone = zone_fixture()
      assert AssetConfig.get_zone!(zone.id) == zone
    end

    test "create_zone/1 with valid data creates a zone" do
      assert {:ok, %Zone{} = zone} = AssetConfig.create_zone(@valid_attrs)
      assert zone.description == "some description"
      assert zone.name == "some name"
      assert zone.path == []
    end

    test "create_zone/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetConfig.create_zone(@invalid_attrs)
    end

    test "update_zone/2 with valid data updates the zone" do
      zone = zone_fixture()
      assert {:ok, %Zone{} = zone} = AssetConfig.update_zone(zone, @update_attrs)
      assert zone.description == "some updated description"
      assert zone.name == "some updated name"
      assert zone.path == []
    end

    test "update_zone/2 with invalid data returns error changeset" do
      zone = zone_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetConfig.update_zone(zone, @invalid_attrs)
      assert zone == AssetConfig.get_zone!(zone.id)
    end

    test "delete_zone/1 deletes the zone" do
      zone = zone_fixture()
      assert {:ok, %Zone{}} = AssetConfig.delete_zone(zone)
      assert_raise Ecto.NoResultsError, fn -> AssetConfig.get_zone!(zone.id) end
    end

    test "change_zone/1 returns a zone changeset" do
      zone = zone_fixture()
      assert %Ecto.Changeset{} = AssetConfig.change_zone(zone)
    end
  end
end

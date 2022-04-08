defmodule Inconn2Service.CommonTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Common

  describe "timezones" do
    alias Inconn2Service.Common.Timezone

    @valid_attrs %{city: "some city", city_low: "some city_low", city_stripped: "some city_stripped", continent: "some continent", label: "some label", state: "some state", utc_offset_seconds: 42, utc_offset_text: "some utc_offset_text"}
    @update_attrs %{city: "some updated city", city_low: "some updated city_low", city_stripped: "some updated city_stripped", continent: "some updated continent", label: "some updated label", state: "some updated state", utc_offset_seconds: 43, utc_offset_text: "some updated utc_offset_text"}
    @invalid_attrs %{city: nil, city_low: nil, city_stripped: nil, continent: nil, label: nil, state: nil, utc_offset_seconds: nil, utc_offset_text: nil}

    def timezone_fixture(attrs \\ %{}) do
      {:ok, timezone} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_timezone()

      timezone
    end

    test "list_timezones/0 returns all timezones" do
      timezone = timezone_fixture()
      assert Common.list_timezones() == [timezone]
    end

    test "get_timezone!/1 returns the timezone with given id" do
      timezone = timezone_fixture()
      assert Common.get_timezone!(timezone.id) == timezone
    end

    test "create_timezone/1 with valid data creates a timezone" do
      assert {:ok, %Timezone{} = timezone} = Common.create_timezone(@valid_attrs)
      assert timezone.city == "some city"
      assert timezone.city_low == "some city_low"
      assert timezone.city_stripped == "some city_stripped"
      assert timezone.continent == "some continent"
      assert timezone.label == "some label"
      assert timezone.state == "some state"
      assert timezone.utc_offset_seconds == 42
      assert timezone.utc_offset_text == "some utc_offset_text"
    end

    test "create_timezone/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_timezone(@invalid_attrs)
    end

    test "update_timezone/2 with valid data updates the timezone" do
      timezone = timezone_fixture()
      assert {:ok, %Timezone{} = timezone} = Common.update_timezone(timezone, @update_attrs)
      assert timezone.city == "some updated city"
      assert timezone.city_low == "some updated city_low"
      assert timezone.city_stripped == "some updated city_stripped"
      assert timezone.continent == "some updated continent"
      assert timezone.label == "some updated label"
      assert timezone.state == "some updated state"
      assert timezone.utc_offset_seconds == 43
      assert timezone.utc_offset_text == "some updated utc_offset_text"
    end

    test "update_timezone/2 with invalid data returns error changeset" do
      timezone = timezone_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_timezone(timezone, @invalid_attrs)
      assert timezone == Common.get_timezone!(timezone.id)
    end

    test "delete_timezone/1 deletes the timezone" do
      timezone = timezone_fixture()
      assert {:ok, %Timezone{}} = Common.delete_timezone(timezone)
      assert_raise Ecto.NoResultsError, fn -> Common.get_timezone!(timezone.id) end
    end

    test "change_timezone/1 returns a timezone changeset" do
      timezone = timezone_fixture()
      assert %Ecto.Changeset{} = Common.change_timezone(timezone)
    end
  end

  describe "iot_meterings" do
    alias Inconn2Service.Common.IotMetering

    @valid_attrs %{equipment_readings: %{}, processed: true}
    @update_attrs %{equipment_readings: %{}, processed: false}
    @invalid_attrs %{equipment_readings: nil, processed: nil}

    def iot_metering_fixture(attrs \\ %{}) do
      {:ok, iot_metering} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_iot_metering()

      iot_metering
    end

    test "list_iot_meterings/0 returns all iot_meterings" do
      iot_metering = iot_metering_fixture()
      assert Common.list_iot_meterings() == [iot_metering]
    end

    test "get_iot_metering!/1 returns the iot_metering with given id" do
      iot_metering = iot_metering_fixture()
      assert Common.get_iot_metering!(iot_metering.id) == iot_metering
    end

    test "create_iot_metering/1 with valid data creates a iot_metering" do
      assert {:ok, %IotMetering{} = iot_metering} = Common.create_iot_metering(@valid_attrs)
      assert iot_metering.equipment_readings == %{}
      assert iot_metering.processed == true
    end

    test "create_iot_metering/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_iot_metering(@invalid_attrs)
    end

    test "update_iot_metering/2 with valid data updates the iot_metering" do
      iot_metering = iot_metering_fixture()
      assert {:ok, %IotMetering{} = iot_metering} = Common.update_iot_metering(iot_metering, @update_attrs)
      assert iot_metering.equipment_readings == %{}
      assert iot_metering.processed == false
    end

    test "update_iot_metering/2 with invalid data returns error changeset" do
      iot_metering = iot_metering_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_iot_metering(iot_metering, @invalid_attrs)
      assert iot_metering == Common.get_iot_metering!(iot_metering.id)
    end

    test "delete_iot_metering/1 deletes the iot_metering" do
      iot_metering = iot_metering_fixture()
      assert {:ok, %IotMetering{}} = Common.delete_iot_metering(iot_metering)
      assert_raise Ecto.NoResultsError, fn -> Common.get_iot_metering!(iot_metering.id) end
    end

    test "change_iot_metering/1 returns a iot_metering changeset" do
      iot_metering = iot_metering_fixture()
      assert %Ecto.Changeset{} = Common.change_iot_metering(iot_metering)
    end
  end

  describe "list_of_values" do
    alias Inconn2Service.Common.ListOfValue

    @valid_attrs %{name: "some name", values: []}
    @update_attrs %{name: "some updated name", values: []}
    @invalid_attrs %{name: nil, values: nil}

    def list_of_value_fixture(attrs \\ %{}) do
      {:ok, list_of_value} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_list_of_value()

      list_of_value
    end

    test "list_list_of_values/0 returns all list_of_values" do
      list_of_value = list_of_value_fixture()
      assert Common.list_list_of_values() == [list_of_value]
    end

    test "get_list_of_value!/1 returns the list_of_value with given id" do
      list_of_value = list_of_value_fixture()
      assert Common.get_list_of_value!(list_of_value.id) == list_of_value
    end

    test "create_list_of_value/1 with valid data creates a list_of_value" do
      assert {:ok, %ListOfValue{} = list_of_value} = Common.create_list_of_value(@valid_attrs)
      assert list_of_value.name == "some name"
      assert list_of_value.values == []
    end

    test "create_list_of_value/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_list_of_value(@invalid_attrs)
    end

    test "update_list_of_value/2 with valid data updates the list_of_value" do
      list_of_value = list_of_value_fixture()
      assert {:ok, %ListOfValue{} = list_of_value} = Common.update_list_of_value(list_of_value, @update_attrs)
      assert list_of_value.name == "some updated name"
      assert list_of_value.values == []
    end

    test "update_list_of_value/2 with invalid data returns error changeset" do
      list_of_value = list_of_value_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_list_of_value(list_of_value, @invalid_attrs)
      assert list_of_value == Common.get_list_of_value!(list_of_value.id)
    end

    test "delete_list_of_value/1 deletes the list_of_value" do
      list_of_value = list_of_value_fixture()
      assert {:ok, %ListOfValue{}} = Common.delete_list_of_value(list_of_value)
      assert_raise Ecto.NoResultsError, fn -> Common.get_list_of_value!(list_of_value.id) end
    end

    test "change_list_of_value/1 returns a list_of_value changeset" do
      list_of_value = list_of_value_fixture()
      assert %Ecto.Changeset{} = Common.change_list_of_value(list_of_value)
    end
  end

  describe "alert_notification_reserves" do
    alias Inconn2Service.Common.AlertNotificationReserve

    @valid_attrs %{addressed_to_user_ids: [], code: "some code", description: "some description", module: "some module", type: "some type"}
    @update_attrs %{addressed_to_user_ids: [], code: "some updated code", description: "some updated description", module: "some updated module", type: "some updated type"}
    @invalid_attrs %{addressed_to_user_ids: nil, code: nil, description: nil, module: nil, type: nil}

    def alert_notification_reserve_fixture(attrs \\ %{}) do
      {:ok, alert_notification_reserve} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_alert_notification_reserve()

      alert_notification_reserve
    end

    test "list_alert_notification_reserves/0 returns all alert_notification_reserves" do
      alert_notification_reserve = alert_notification_reserve_fixture()
      assert Common.list_alert_notification_reserves() == [alert_notification_reserve]
    end

    test "get_alert_notification_reserve!/1 returns the alert_notification_reserve with given id" do
      alert_notification_reserve = alert_notification_reserve_fixture()
      assert Common.get_alert_notification_reserve!(alert_notification_reserve.id) == alert_notification_reserve
    end

    test "create_alert_notification_reserve/1 with valid data creates a alert_notification_reserve" do
      assert {:ok, %AlertNotificationReserve{} = alert_notification_reserve} = Common.create_alert_notification_reserve(@valid_attrs)
      assert alert_notification_reserve.addressed_to_user_ids == []
      assert alert_notification_reserve.code == "some code"
      assert alert_notification_reserve.description == "some description"
      assert alert_notification_reserve.module == "some module"
      assert alert_notification_reserve.type == "some type"
    end

    test "create_alert_notification_reserve/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_alert_notification_reserve(@invalid_attrs)
    end

    test "update_alert_notification_reserve/2 with valid data updates the alert_notification_reserve" do
      alert_notification_reserve = alert_notification_reserve_fixture()
      assert {:ok, %AlertNotificationReserve{} = alert_notification_reserve} = Common.update_alert_notification_reserve(alert_notification_reserve, @update_attrs)
      assert alert_notification_reserve.addressed_to_user_ids == []
      assert alert_notification_reserve.code == "some updated code"
      assert alert_notification_reserve.description == "some updated description"
      assert alert_notification_reserve.module == "some updated module"
      assert alert_notification_reserve.type == "some updated type"
    end

    test "update_alert_notification_reserve/2 with invalid data returns error changeset" do
      alert_notification_reserve = alert_notification_reserve_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_alert_notification_reserve(alert_notification_reserve, @invalid_attrs)
      assert alert_notification_reserve == Common.get_alert_notification_reserve!(alert_notification_reserve.id)
    end

    test "delete_alert_notification_reserve/1 deletes the alert_notification_reserve" do
      alert_notification_reserve = alert_notification_reserve_fixture()
      assert {:ok, %AlertNotificationReserve{}} = Common.delete_alert_notification_reserve(alert_notification_reserve)
      assert_raise Ecto.NoResultsError, fn -> Common.get_alert_notification_reserve!(alert_notification_reserve.id) end
    end

    test "change_alert_notification_reserve/1 returns a alert_notification_reserve changeset" do
      alert_notification_reserve = alert_notification_reserve_fixture()
      assert %Ecto.Changeset{} = Common.change_alert_notification_reserve(alert_notification_reserve)
    end
  end
end

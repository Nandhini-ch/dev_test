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

  describe "alert_notification_generators" do
    alias Inconn2Service.Common.AlertNotificationGenerator

    @valid_attrs %{code: "some code", prefix: "some prefix", reference_id: 42, utc_date_time: "2010-04-17T14:00:00Z", zone: "some zone"}
    @update_attrs %{code: "some updated code", prefix: "some updated prefix", reference_id: 43, utc_date_time: "2011-05-18T15:01:01Z", zone: "some updated zone"}
    @invalid_attrs %{code: nil, prefix: nil, reference_id: nil, utc_date_time: nil, zone: nil}

    def alert_notification_generator_fixture(attrs \\ %{}) do
      {:ok, alert_notification_generator} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_alert_notification_generator()

      alert_notification_generator
    end

    test "list_alert_notification_generators/0 returns all alert_notification_generators" do
      alert_notification_generator = alert_notification_generator_fixture()
      assert Common.list_alert_notification_generators() == [alert_notification_generator]
    end

    test "get_alert_notification_generator!/1 returns the alert_notification_generator with given id" do
      alert_notification_generator = alert_notification_generator_fixture()
      assert Common.get_alert_notification_generator!(alert_notification_generator.id) == alert_notification_generator
    end

    test "create_alert_notification_generator/1 with valid data creates a alert_notification_generator" do
      assert {:ok, %AlertNotificationGenerator{} = alert_notification_generator} = Common.create_alert_notification_generator(@valid_attrs)
      assert alert_notification_generator.code == "some code"
      assert alert_notification_generator.prefix == "some prefix"
      assert alert_notification_generator.reference_id == 42
      assert alert_notification_generator.utc_date_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert alert_notification_generator.zone == "some zone"
    end

    test "create_alert_notification_generator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_alert_notification_generator(@invalid_attrs)
    end

    test "update_alert_notification_generator/2 with valid data updates the alert_notification_generator" do
      alert_notification_generator = alert_notification_generator_fixture()
      assert {:ok, %AlertNotificationGenerator{} = alert_notification_generator} = Common.update_alert_notification_generator(alert_notification_generator, @update_attrs)
      assert alert_notification_generator.code == "some updated code"
      assert alert_notification_generator.prefix == "some updated prefix"
      assert alert_notification_generator.reference_id == 43
      assert alert_notification_generator.utc_date_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert alert_notification_generator.zone == "some updated zone"
    end

    test "update_alert_notification_generator/2 with invalid data returns error changeset" do
      alert_notification_generator = alert_notification_generator_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_alert_notification_generator(alert_notification_generator, @invalid_attrs)
      assert alert_notification_generator == Common.get_alert_notification_generator!(alert_notification_generator.id)
    end

    test "delete_alert_notification_generator/1 deletes the alert_notification_generator" do
      alert_notification_generator = alert_notification_generator_fixture()
      assert {:ok, %AlertNotificationGenerator{}} = Common.delete_alert_notification_generator(alert_notification_generator)
      assert_raise Ecto.NoResultsError, fn -> Common.get_alert_notification_generator!(alert_notification_generator.id) end
    end

    test "change_alert_notification_generator/1 returns a alert_notification_generator changeset" do
      alert_notification_generator = alert_notification_generator_fixture()
      assert %Ecto.Changeset{} = Common.change_alert_notification_generator(alert_notification_generator)
    end
  end

  describe "alert_notification_schedulers" do
    alias Inconn2Service.Common.AlertNotificationScheduler

    @valid_attrs %{alert_code: "some alert_code", alert_identifier_date_time: ~N[2010-04-17 14:00:00], escalation_at_date_time: ~N[2010-04-17 14:00:00], site_id: 42}
    @update_attrs %{alert_code: "some updated alert_code", alert_identifier_date_time: ~N[2011-05-18 15:01:01], escalation_at_date_time: ~N[2011-05-18 15:01:01], site_id: 43}
    @invalid_attrs %{alert_code: nil, alert_identifier_date_time: nil, escalation_at_date_time: nil, site_id: nil}

    def alert_notification_scheduler_fixture(attrs \\ %{}) do
      {:ok, alert_notification_scheduler} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_alert_notification_scheduler()

      alert_notification_scheduler
    end

    test "list_alert_notification_schedulers/0 returns all alert_notification_schedulers" do
      alert_notification_scheduler = alert_notification_scheduler_fixture()
      assert Common.list_alert_notification_schedulers() == [alert_notification_scheduler]
    end

    test "get_alert_notification_scheduler!/1 returns the alert_notification_scheduler with given id" do
      alert_notification_scheduler = alert_notification_scheduler_fixture()
      assert Common.get_alert_notification_scheduler!(alert_notification_scheduler.id) == alert_notification_scheduler
    end

    test "create_alert_notification_scheduler/1 with valid data creates a alert_notification_scheduler" do
      assert {:ok, %AlertNotificationScheduler{} = alert_notification_scheduler} = Common.create_alert_notification_scheduler(@valid_attrs)
      assert alert_notification_scheduler.alert_code == "some alert_code"
      assert alert_notification_scheduler.alert_identifier_date_time == ~N[2010-04-17 14:00:00]
      assert alert_notification_scheduler.escalation_at_date_time == ~N[2010-04-17 14:00:00]
      assert alert_notification_scheduler.site_id == 42
    end

    test "create_alert_notification_scheduler/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_alert_notification_scheduler(@invalid_attrs)
    end

    test "update_alert_notification_scheduler/2 with valid data updates the alert_notification_scheduler" do
      alert_notification_scheduler = alert_notification_scheduler_fixture()
      assert {:ok, %AlertNotificationScheduler{} = alert_notification_scheduler} = Common.update_alert_notification_scheduler(alert_notification_scheduler, @update_attrs)
      assert alert_notification_scheduler.alert_code == "some updated alert_code"
      assert alert_notification_scheduler.alert_identifier_date_time == ~N[2011-05-18 15:01:01]
      assert alert_notification_scheduler.escalation_at_date_time == ~N[2011-05-18 15:01:01]
      assert alert_notification_scheduler.site_id == 43
    end

    test "update_alert_notification_scheduler/2 with invalid data returns error changeset" do
      alert_notification_scheduler = alert_notification_scheduler_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_alert_notification_scheduler(alert_notification_scheduler, @invalid_attrs)
      assert alert_notification_scheduler == Common.get_alert_notification_scheduler!(alert_notification_scheduler.id)
    end

    test "delete_alert_notification_scheduler/1 deletes the alert_notification_scheduler" do
      alert_notification_scheduler = alert_notification_scheduler_fixture()
      assert {:ok, %AlertNotificationScheduler{}} = Common.delete_alert_notification_scheduler(alert_notification_scheduler)
      assert_raise Ecto.NoResultsError, fn -> Common.get_alert_notification_scheduler!(alert_notification_scheduler.id) end
    end

    test "change_alert_notification_scheduler/1 returns a alert_notification_scheduler changeset" do
      alert_notification_scheduler = alert_notification_scheduler_fixture()
      assert %Ecto.Changeset{} = Common.change_alert_notification_scheduler(alert_notification_scheduler)
    end
  end

  describe "widgets" do
    alias Inconn2Service.Common.Widget

    @valid_attrs %{code: "some code", description: "some description", title: "some title"}
    @update_attrs %{code: "some updated code", description: "some updated description", title: "some updated title"}
    @invalid_attrs %{code: nil, description: nil, title: nil}

    def widget_fixture(attrs \\ %{}) do
      {:ok, widget} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_widget()

      widget
    end

    test "list_widgets/0 returns all widgets" do
      widget = widget_fixture()
      assert Common.list_widgets() == [widget]
    end

    test "get_widget!/1 returns the widget with given id" do
      widget = widget_fixture()
      assert Common.get_widget!(widget.id) == widget
    end

    test "create_widget/1 with valid data creates a widget" do
      assert {:ok, %Widget{} = widget} = Common.create_widget(@valid_attrs)
      assert widget.code == "some code"
      assert widget.description == "some description"
      assert widget.title == "some title"
    end

    test "create_widget/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_widget(@invalid_attrs)
    end

    test "update_widget/2 with valid data updates the widget" do
      widget = widget_fixture()
      assert {:ok, %Widget{} = widget} = Common.update_widget(widget, @update_attrs)
      assert widget.code == "some updated code"
      assert widget.description == "some updated description"
      assert widget.title == "some updated title"
    end

    test "update_widget/2 with invalid data returns error changeset" do
      widget = widget_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_widget(widget, @invalid_attrs)
      assert widget == Common.get_widget!(widget.id)
    end

    test "delete_widget/1 deletes the widget" do
      widget = widget_fixture()
      assert {:ok, %Widget{}} = Common.delete_widget(widget)
      assert_raise Ecto.NoResultsError, fn -> Common.get_widget!(widget.id) end
    end

    test "change_widget/1 returns a widget changeset" do
      widget = widget_fixture()
      assert %Ecto.Changeset{} = Common.change_widget(widget)
    end
  end

  describe "admin_user" do
    alias Inconn2Service.Common.AdminUser

    @valid_attrs %{email: "some email", full_name: "some full_name", password: "some password", phone_no: "some phone_no"}
    @update_attrs %{email: "some updated email", full_name: "some updated full_name", password: "some updated password", phone_no: "some updated phone_no"}
    @invalid_attrs %{email: nil, full_name: nil, password: nil, phone_no: nil}

    def admin_user_fixture(attrs \\ %{}) do
      {:ok, admin_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_admin_user()

      admin_user
    end

    test "list_admin_user/0 returns all admin_user" do
      admin_user = admin_user_fixture()
      assert Common.list_admin_user() == [admin_user]
    end

    test "get_admin_user!/1 returns the admin_user with given id" do
      admin_user = admin_user_fixture()
      assert Common.get_admin_user!(admin_user.id) == admin_user
    end

    test "create_admin_user/1 with valid data creates a admin_user" do
      assert {:ok, %AdminUser{} = admin_user} = Common.create_admin_user(@valid_attrs)
      assert admin_user.email == "some email"
      assert admin_user.full_name == "some full_name"
      assert admin_user.password == "some password"
      assert admin_user.phone_no == "some phone_no"
    end

    test "create_admin_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_admin_user(@invalid_attrs)
    end

    test "update_admin_user/2 with valid data updates the admin_user" do
      admin_user = admin_user_fixture()
      assert {:ok, %AdminUser{} = admin_user} = Common.update_admin_user(admin_user, @update_attrs)
      assert admin_user.email == "some updated email"
      assert admin_user.full_name == "some updated full_name"
      assert admin_user.password == "some updated password"
      assert admin_user.phone_no == "some updated phone_no"
    end

    test "update_admin_user/2 with invalid data returns error changeset" do
      admin_user = admin_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_admin_user(admin_user, @invalid_attrs)
      assert admin_user == Common.get_admin_user!(admin_user.id)
    end

    test "delete_admin_user/1 deletes the admin_user" do
      admin_user = admin_user_fixture()
      assert {:ok, %AdminUser{}} = Common.delete_admin_user(admin_user)
      assert_raise Ecto.NoResultsError, fn -> Common.get_admin_user!(admin_user.id) end
    end

    test "change_admin_user/1 returns a admin_user changeset" do
      admin_user = admin_user_fixture()
      assert %Ecto.Changeset{} = Common.change_admin_user(admin_user)
    end
  end

  describe "public_uoms" do
    alias Inconn2Service.Common.PublicUom

    @valid_attrs %{description: "some description", uom_category: "some uom_category", uom_unit: "some uom_unit"}
    @update_attrs %{description: "some updated description", uom_category: "some updated uom_category", uom_unit: "some updated uom_unit"}
    @invalid_attrs %{description: nil, uom_category: nil, uom_unit: nil}

    def public_uom_fixture(attrs \\ %{}) do
      {:ok, public_uom} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_public_uom()

      public_uom
    end

    test "list_public_uoms/0 returns all public_uoms" do
      public_uom = public_uom_fixture()
      assert Common.list_public_uoms() == [public_uom]
    end

    test "get_public_uom!/1 returns the public_uom with given id" do
      public_uom = public_uom_fixture()
      assert Common.get_public_uom!(public_uom.id) == public_uom
    end

    test "create_public_uom/1 with valid data creates a public_uom" do
      assert {:ok, %PublicUom{} = public_uom} = Common.create_public_uom(@valid_attrs)
      assert public_uom.description == "some description"
      assert public_uom.uom_category == "some uom_category"
      assert public_uom.uom_unit == "some uom_unit"
    end

    test "create_public_uom/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_public_uom(@invalid_attrs)
    end

    test "update_public_uom/2 with valid data updates the public_uom" do
      public_uom = public_uom_fixture()
      assert {:ok, %PublicUom{} = public_uom} = Common.update_public_uom(public_uom, @update_attrs)
      assert public_uom.description == "some updated description"
      assert public_uom.uom_category == "some updated uom_category"
      assert public_uom.uom_unit == "some updated uom_unit"
    end

    test "update_public_uom/2 with invalid data returns error changeset" do
      public_uom = public_uom_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_public_uom(public_uom, @invalid_attrs)
      assert public_uom == Common.get_public_uom!(public_uom.id)
    end

    test "delete_public_uom/1 deletes the public_uom" do
      public_uom = public_uom_fixture()
      assert {:ok, %PublicUom{}} = Common.delete_public_uom(public_uom)
      assert_raise Ecto.NoResultsError, fn -> Common.get_public_uom!(public_uom.id) end
    end

    test "change_public_uom/1 returns a public_uom changeset" do
      public_uom = public_uom_fixture()
      assert %Ecto.Changeset{} = Common.change_public_uom(public_uom)
    end
  end

  describe "work_request_close_schedulers" do
    alias Inconn2Service.Common.WorkRequestCloseScheduler

    @valid_attrs %{prefix: "some prefix", time_zone: "some time_zone", utc_date_time: "2010-04-17T14:00:00Z", work_request_id: 42}
    @update_attrs %{prefix: "some updated prefix", time_zone: "some updated time_zone", utc_date_time: "2011-05-18T15:01:01Z", work_request_id: 43}
    @invalid_attrs %{prefix: nil, time_zone: nil, utc_date_time: nil, work_request_id: nil}

    def work_request_close_scheduler_fixture(attrs \\ %{}) do
      {:ok, work_request_close_scheduler} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Common.create_work_request_close_scheduler()

      work_request_close_scheduler
    end

    test "list_work_request_close_schedulers/0 returns all work_request_close_schedulers" do
      work_request_close_scheduler = work_request_close_scheduler_fixture()
      assert Common.list_work_request_close_schedulers() == [work_request_close_scheduler]
    end

    test "get_work_request_close_scheduler!/1 returns the work_request_close_scheduler with given id" do
      work_request_close_scheduler = work_request_close_scheduler_fixture()
      assert Common.get_work_request_close_scheduler!(work_request_close_scheduler.id) == work_request_close_scheduler
    end

    test "create_work_request_close_scheduler/1 with valid data creates a work_request_close_scheduler" do
      assert {:ok, %WorkRequestCloseScheduler{} = work_request_close_scheduler} = Common.create_work_request_close_scheduler(@valid_attrs)
      assert work_request_close_scheduler.prefix == "some prefix"
      assert work_request_close_scheduler.time_zone == "some time_zone"
      assert work_request_close_scheduler.utc_date_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert work_request_close_scheduler.work_request_id == 42
    end

    test "create_work_request_close_scheduler/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Common.create_work_request_close_scheduler(@invalid_attrs)
    end

    test "update_work_request_close_scheduler/2 with valid data updates the work_request_close_scheduler" do
      work_request_close_scheduler = work_request_close_scheduler_fixture()
      assert {:ok, %WorkRequestCloseScheduler{} = work_request_close_scheduler} = Common.update_work_request_close_scheduler(work_request_close_scheduler, @update_attrs)
      assert work_request_close_scheduler.prefix == "some updated prefix"
      assert work_request_close_scheduler.time_zone == "some updated time_zone"
      assert work_request_close_scheduler.utc_date_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert work_request_close_scheduler.work_request_id == 43
    end

    test "update_work_request_close_scheduler/2 with invalid data returns error changeset" do
      work_request_close_scheduler = work_request_close_scheduler_fixture()
      assert {:error, %Ecto.Changeset{}} = Common.update_work_request_close_scheduler(work_request_close_scheduler, @invalid_attrs)
      assert work_request_close_scheduler == Common.get_work_request_close_scheduler!(work_request_close_scheduler.id)
    end

    test "delete_work_request_close_scheduler/1 deletes the work_request_close_scheduler" do
      work_request_close_scheduler = work_request_close_scheduler_fixture()
      assert {:ok, %WorkRequestCloseScheduler{}} = Common.delete_work_request_close_scheduler(work_request_close_scheduler)
      assert_raise Ecto.NoResultsError, fn -> Common.get_work_request_close_scheduler!(work_request_close_scheduler.id) end
    end

    test "change_work_request_close_scheduler/1 returns a work_request_close_scheduler changeset" do
      work_request_close_scheduler = work_request_close_scheduler_fixture()
      assert %Ecto.Changeset{} = Common.change_work_request_close_scheduler(work_request_close_scheduler)
    end
  end
end

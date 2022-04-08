defmodule Inconn2Service.PromptTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Prompt

  describe "alert_notifications" do
    alias Inconn2Service.Prompt.AlertNotificationConfig

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def alert_notification_config_fixture(attrs \\ %{}) do
      {:ok, alert_notification_config} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Prompt.create_alert_notification_config()

      alert_notification_config
    end

    test "list_alert_notifications/0 returns all alert_notifications" do
      alert_notification_config = alert_notification_config_fixture()
      assert Prompt.list_alert_notifications() == [alert_notification_config]
    end

    test "get_alert_notification_config!/1 returns the alert_notification_config with given id" do
      alert_notification_config = alert_notification_config_fixture()
      assert Prompt.get_alert_notification_config!(alert_notification_config.id) == alert_notification_config
    end

    test "create_alert_notification_config/1 with valid data creates a alert_notification_config" do
      assert {:ok, %AlertNotificationConfig{} = alert_notification_config} = Prompt.create_alert_notification_config(@valid_attrs)
    end

    test "create_alert_notification_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prompt.create_alert_notification_config(@invalid_attrs)
    end

    test "update_alert_notification_config/2 with valid data updates the alert_notification_config" do
      alert_notification_config = alert_notification_config_fixture()
      assert {:ok, %AlertNotificationConfig{} = alert_notification_config} = Prompt.update_alert_notification_config(alert_notification_config, @update_attrs)
    end

    test "update_alert_notification_config/2 with invalid data returns error changeset" do
      alert_notification_config = alert_notification_config_fixture()
      assert {:error, %Ecto.Changeset{}} = Prompt.update_alert_notification_config(alert_notification_config, @invalid_attrs)
      assert alert_notification_config == Prompt.get_alert_notification_config!(alert_notification_config.id)
    end

    test "delete_alert_notification_config/1 deletes the alert_notification_config" do
      alert_notification_config = alert_notification_config_fixture()
      assert {:ok, %AlertNotificationConfig{}} = Prompt.delete_alert_notification_config(alert_notification_config)
      assert_raise Ecto.NoResultsError, fn -> Prompt.get_alert_notification_config!(alert_notification_config.id) end
    end

    test "change_alert_notification_config/1 returns a alert_notification_config changeset" do
      alert_notification_config = alert_notification_config_fixture()
      assert %Ecto.Changeset{} = Prompt.change_alert_notification_config(alert_notification_config)
    end
  end

  describe "alert_notification_configs" do
    alias Inconn2Service.Prompt.AlertNotificationConfig

    @valid_attrs %{addressed_to_user_ids: [], alert_notification_reserve_id: 42}
    @update_attrs %{addressed_to_user_ids: [], alert_notification_reserve_id: 43}
    @invalid_attrs %{addressed_to_user_ids: nil, alert_notification_reserve_id: nil}

    def alert_notification_config_fixture(attrs \\ %{}) do
      {:ok, alert_notification_config} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Prompt.create_alert_notification_config()

      alert_notification_config
    end

    test "list_alert_notification_configs/0 returns all alert_notification_configs" do
      alert_notification_config = alert_notification_config_fixture()
      assert Prompt.list_alert_notification_configs() == [alert_notification_config]
    end

    test "get_alert_notification_config!/1 returns the alert_notification_config with given id" do
      alert_notification_config = alert_notification_config_fixture()
      assert Prompt.get_alert_notification_config!(alert_notification_config.id) == alert_notification_config
    end

    test "create_alert_notification_config/1 with valid data creates a alert_notification_config" do
      assert {:ok, %AlertNotificationConfig{} = alert_notification_config} = Prompt.create_alert_notification_config(@valid_attrs)
      assert alert_notification_config.addressed_to_user_ids == []
      assert alert_notification_config.alert_notification_reserve_id == 42
    end

    test "create_alert_notification_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prompt.create_alert_notification_config(@invalid_attrs)
    end

    test "update_alert_notification_config/2 with valid data updates the alert_notification_config" do
      alert_notification_config = alert_notification_config_fixture()
      assert {:ok, %AlertNotificationConfig{} = alert_notification_config} = Prompt.update_alert_notification_config(alert_notification_config, @update_attrs)
      assert alert_notification_config.addressed_to_user_ids == []
      assert alert_notification_config.alert_notification_reserve_id == 43
    end

    test "update_alert_notification_config/2 with invalid data returns error changeset" do
      alert_notification_config = alert_notification_config_fixture()
      assert {:error, %Ecto.Changeset{}} = Prompt.update_alert_notification_config(alert_notification_config, @invalid_attrs)
      assert alert_notification_config == Prompt.get_alert_notification_config!(alert_notification_config.id)
    end

    test "delete_alert_notification_config/1 deletes the alert_notification_config" do
      alert_notification_config = alert_notification_config_fixture()
      assert {:ok, %AlertNotificationConfig{}} = Prompt.delete_alert_notification_config(alert_notification_config)
      assert_raise Ecto.NoResultsError, fn -> Prompt.get_alert_notification_config!(alert_notification_config.id) end
    end

    test "change_alert_notification_config/1 returns a alert_notification_config changeset" do
      alert_notification_config = alert_notification_config_fixture()
      assert %Ecto.Changeset{} = Prompt.change_alert_notification_config(alert_notification_config)
    end
  end

  describe "user_alerts" do
    alias Inconn2Service.Prompt.UserAlert

    @valid_attrs %{alert_id: 42, alert_type: "some alert_type", asset_id: 42, user_id: 42}
    @update_attrs %{alert_id: 43, alert_type: "some updated alert_type", asset_id: 43, user_id: 43}
    @invalid_attrs %{alert_id: nil, alert_type: nil, asset_id: nil, user_id: nil}

    def user_alert_fixture(attrs \\ %{}) do
      {:ok, user_alert} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Prompt.create_user_alert()

      user_alert
    end

    test "list_user_alerts/0 returns all user_alerts" do
      user_alert = user_alert_fixture()
      assert Prompt.list_user_alerts() == [user_alert]
    end

    test "get_user_alert!/1 returns the user_alert with given id" do
      user_alert = user_alert_fixture()
      assert Prompt.get_user_alert!(user_alert.id) == user_alert
    end

    test "create_user_alert/1 with valid data creates a user_alert" do
      assert {:ok, %UserAlert{} = user_alert} = Prompt.create_user_alert(@valid_attrs)
      assert user_alert.alert_id == 42
      assert user_alert.alert_type == "some alert_type"
      assert user_alert.asset_id == 42
      assert user_alert.user_id == 42
    end

    test "create_user_alert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prompt.create_user_alert(@invalid_attrs)
    end

    test "update_user_alert/2 with valid data updates the user_alert" do
      user_alert = user_alert_fixture()
      assert {:ok, %UserAlert{} = user_alert} = Prompt.update_user_alert(user_alert, @update_attrs)
      assert user_alert.alert_id == 43
      assert user_alert.alert_type == "some updated alert_type"
      assert user_alert.asset_id == 43
      assert user_alert.user_id == 43
    end

    test "update_user_alert/2 with invalid data returns error changeset" do
      user_alert = user_alert_fixture()
      assert {:error, %Ecto.Changeset{}} = Prompt.update_user_alert(user_alert, @invalid_attrs)
      assert user_alert == Prompt.get_user_alert!(user_alert.id)
    end

    test "delete_user_alert/1 deletes the user_alert" do
      user_alert = user_alert_fixture()
      assert {:ok, %UserAlert{}} = Prompt.delete_user_alert(user_alert)
      assert_raise Ecto.NoResultsError, fn -> Prompt.get_user_alert!(user_alert.id) end
    end

    test "change_user_alert/1 returns a user_alert changeset" do
      user_alert = user_alert_fixture()
      assert %Ecto.Changeset{} = Prompt.change_user_alert(user_alert)
    end
  end
end

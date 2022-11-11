defmodule Inconn2Service.DashboardConfigurationTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.DashboardConfiguration

  describe "user_widget_configs" do
    alias Inconn2Service.DashboardConfiguration.UserWidgetConfig

    @valid_attrs %{position: 42, widget_code: "some widget_code"}
    @update_attrs %{position: 43, widget_code: "some updated widget_code"}
    @invalid_attrs %{position: nil, widget_code: nil}

    def user_widget_config_fixture(attrs \\ %{}) do
      {:ok, user_widget_config} =
        attrs
        |> Enum.into(@valid_attrs)
        |> DashboardConfiguration.create_user_widget_config()

      user_widget_config
    end

    test "list_user_widget_configs/0 returns all user_widget_configs" do
      user_widget_config = user_widget_config_fixture()
      assert DashboardConfiguration.list_user_widget_configs() == [user_widget_config]
    end

    test "get_user_widget_config!/1 returns the user_widget_config with given id" do
      user_widget_config = user_widget_config_fixture()
      assert DashboardConfiguration.get_user_widget_config!(user_widget_config.id) == user_widget_config
    end

    test "create_user_widget_config/1 with valid data creates a user_widget_config" do
      assert {:ok, %UserWidgetConfig{} = user_widget_config} = DashboardConfiguration.create_user_widget_config(@valid_attrs)
      assert user_widget_config.position == 42
      assert user_widget_config.widget_code == "some widget_code"
    end

    test "create_user_widget_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DashboardConfiguration.create_user_widget_config(@invalid_attrs)
    end

    test "update_user_widget_config/2 with valid data updates the user_widget_config" do
      user_widget_config = user_widget_config_fixture()
      assert {:ok, %UserWidgetConfig{} = user_widget_config} = DashboardConfiguration.update_user_widget_config(user_widget_config, @update_attrs)
      assert user_widget_config.position == 43
      assert user_widget_config.widget_code == "some updated widget_code"
    end

    test "update_user_widget_config/2 with invalid data returns error changeset" do
      user_widget_config = user_widget_config_fixture()
      assert {:error, %Ecto.Changeset{}} = DashboardConfiguration.update_user_widget_config(user_widget_config, @invalid_attrs)
      assert user_widget_config == DashboardConfiguration.get_user_widget_config!(user_widget_config.id)
    end

    test "delete_user_widget_config/1 deletes the user_widget_config" do
      user_widget_config = user_widget_config_fixture()
      assert {:ok, %UserWidgetConfig{}} = DashboardConfiguration.delete_user_widget_config(user_widget_config)
      assert_raise Ecto.NoResultsError, fn -> DashboardConfiguration.get_user_widget_config!(user_widget_config.id) end
    end

    test "change_user_widget_config/1 returns a user_widget_config changeset" do
      user_widget_config = user_widget_config_fixture()
      assert %Ecto.Changeset{} = DashboardConfiguration.change_user_widget_config(user_widget_config)
    end
  end

  describe "saved_dashboard_filters" do
    alias Inconn2Service.DashboardConfiguration.SavedDashboardFilter

    @valid_attrs %{config: %{}, site_id: 42, user_id: 42, widget_code: "some widget_code"}
    @update_attrs %{config: %{}, site_id: 43, user_id: 43, widget_code: "some updated widget_code"}
    @invalid_attrs %{config: nil, site_id: nil, user_id: nil, widget_code: nil}

    def saved_dashboard_filter_fixture(attrs \\ %{}) do
      {:ok, saved_dashboard_filter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> DashboardConfiguration.create_saved_dashboard_filter()

      saved_dashboard_filter
    end

    test "list_saved_dashboard_filters/0 returns all saved_dashboard_filters" do
      saved_dashboard_filter = saved_dashboard_filter_fixture()
      assert DashboardConfiguration.list_saved_dashboard_filters() == [saved_dashboard_filter]
    end

    test "get_saved_dashboard_filter!/1 returns the saved_dashboard_filter with given id" do
      saved_dashboard_filter = saved_dashboard_filter_fixture()
      assert DashboardConfiguration.get_saved_dashboard_filter!(saved_dashboard_filter.id) == saved_dashboard_filter
    end

    test "create_saved_dashboard_filter/1 with valid data creates a saved_dashboard_filter" do
      assert {:ok, %SavedDashboardFilter{} = saved_dashboard_filter} = DashboardConfiguration.create_saved_dashboard_filter(@valid_attrs)
      assert saved_dashboard_filter.config == %{}
      assert saved_dashboard_filter.site_id == 42
      assert saved_dashboard_filter.user_id == 42
      assert saved_dashboard_filter.widget_code == "some widget_code"
    end

    test "create_saved_dashboard_filter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DashboardConfiguration.create_saved_dashboard_filter(@invalid_attrs)
    end

    test "update_saved_dashboard_filter/2 with valid data updates the saved_dashboard_filter" do
      saved_dashboard_filter = saved_dashboard_filter_fixture()
      assert {:ok, %SavedDashboardFilter{} = saved_dashboard_filter} = DashboardConfiguration.update_saved_dashboard_filter(saved_dashboard_filter, @update_attrs)
      assert saved_dashboard_filter.config == %{}
      assert saved_dashboard_filter.site_id == 43
      assert saved_dashboard_filter.user_id == 43
      assert saved_dashboard_filter.widget_code == "some updated widget_code"
    end

    test "update_saved_dashboard_filter/2 with invalid data returns error changeset" do
      saved_dashboard_filter = saved_dashboard_filter_fixture()
      assert {:error, %Ecto.Changeset{}} = DashboardConfiguration.update_saved_dashboard_filter(saved_dashboard_filter, @invalid_attrs)
      assert saved_dashboard_filter == DashboardConfiguration.get_saved_dashboard_filter!(saved_dashboard_filter.id)
    end

    test "delete_saved_dashboard_filter/1 deletes the saved_dashboard_filter" do
      saved_dashboard_filter = saved_dashboard_filter_fixture()
      assert {:ok, %SavedDashboardFilter{}} = DashboardConfiguration.delete_saved_dashboard_filter(saved_dashboard_filter)
      assert_raise Ecto.NoResultsError, fn -> DashboardConfiguration.get_saved_dashboard_filter!(saved_dashboard_filter.id) end
    end

    test "change_saved_dashboard_filter/1 returns a saved_dashboard_filter changeset" do
      saved_dashboard_filter = saved_dashboard_filter_fixture()
      assert %Ecto.Changeset{} = DashboardConfiguration.change_saved_dashboard_filter(saved_dashboard_filter)
    end
  end
end

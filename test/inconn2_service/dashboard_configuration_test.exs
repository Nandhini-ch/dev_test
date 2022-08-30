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
end

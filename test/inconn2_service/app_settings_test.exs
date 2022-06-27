defmodule Inconn2Service.AppSettingsTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.AppSettings

  describe "apk_versions" do
    alias Inconn2Service.AppSettings.Apk_version

    @valid_attrs %{version_no: "some version_no"}
    @update_attrs %{version_no: "some updated version_no"}
    @invalid_attrs %{version_no: nil}

    def apk_version_fixture(attrs \\ %{}) do
      {:ok, apk_version} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AppSettings.create_apk_version()

      apk_version
    end

    test "list_apk_versions/0 returns all apk_versions" do
      apk_version = apk_version_fixture()
      assert AppSettings.list_apk_versions() == [apk_version]
    end

    test "get_apk_version!/1 returns the apk_version with given id" do
      apk_version = apk_version_fixture()
      assert AppSettings.get_apk_version!(apk_version.id) == apk_version
    end

    test "create_apk_version/1 with valid data creates a apk_version" do
      assert {:ok, %Apk_version{} = apk_version} = AppSettings.create_apk_version(@valid_attrs)
      assert apk_version.version_no == "some version_no"
    end

    test "create_apk_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AppSettings.create_apk_version(@invalid_attrs)
    end

    test "update_apk_version/2 with valid data updates the apk_version" do
      apk_version = apk_version_fixture()
      assert {:ok, %Apk_version{} = apk_version} = AppSettings.update_apk_version(apk_version, @update_attrs)
      assert apk_version.version_no == "some updated version_no"
    end

    test "update_apk_version/2 with invalid data returns error changeset" do
      apk_version = apk_version_fixture()
      assert {:error, %Ecto.Changeset{}} = AppSettings.update_apk_version(apk_version, @invalid_attrs)
      assert apk_version == AppSettings.get_apk_version!(apk_version.id)
    end

    test "delete_apk_version/1 deletes the apk_version" do
      apk_version = apk_version_fixture()
      assert {:ok, %Apk_version{}} = AppSettings.delete_apk_version(apk_version)
      assert_raise Ecto.NoResultsError, fn -> AppSettings.get_apk_version!(apk_version.id) end
    end

    test "change_apk_version/1 returns a apk_version changeset" do
      apk_version = apk_version_fixture()
      assert %Ecto.Changeset{} = AppSettings.change_apk_version(apk_version)
    end
  end
end

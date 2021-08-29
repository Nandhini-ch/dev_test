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
end

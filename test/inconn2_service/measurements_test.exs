defmodule Inconn2Service.MeasurementsTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Measurements

  describe "meter_readings" do
    alias Inconn2Service.Measurements.MeterReading

    @valid_attrs %{absolute_value: 120.5, asset_id: 42, asset_type: "some asset_type", cumulative_value: 120.5, recorded_date_time: ~N[2010-04-17 14:00:00], site_id: 42, unit_of_measurement: "some unit_of_measurement", work_order_id: 42}
    @update_attrs %{absolute_value: 456.7, asset_id: 43, asset_type: "some updated asset_type", cumulative_value: 456.7, recorded_date_time: ~N[2011-05-18 15:01:01], site_id: 43, unit_of_measurement: "some updated unit_of_measurement", work_order_id: 43}
    @invalid_attrs %{absolute_value: nil, asset_id: nil, asset_type: nil, cumulative_value: nil, recorded_date_time: nil, site_id: nil, unit_of_measurement: nil, work_order_id: nil}

    def meter_reading_fixture(attrs \\ %{}) do
      {:ok, meter_reading} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Measurements.create_meter_reading()

      meter_reading
    end

    test "list_meter_readings/0 returns all meter_readings" do
      meter_reading = meter_reading_fixture()
      assert Measurements.list_meter_readings() == [meter_reading]
    end

    test "get_meter_reading!/1 returns the meter_reading with given id" do
      meter_reading = meter_reading_fixture()
      assert Measurements.get_meter_reading!(meter_reading.id) == meter_reading
    end

    test "create_meter_reading/1 with valid data creates a meter_reading" do
      assert {:ok, %MeterReading{} = meter_reading} = Measurements.create_meter_reading(@valid_attrs)
      assert meter_reading.absolute_value == 120.5
      assert meter_reading.asset_id == 42
      assert meter_reading.asset_type == "some asset_type"
      assert meter_reading.cumulative_value == 120.5
      assert meter_reading.recorded_date_time == ~N[2010-04-17 14:00:00]
      assert meter_reading.site_id == 42
      assert meter_reading.unit_of_measurement == "some unit_of_measurement"
      assert meter_reading.work_order_id == 42
    end

    test "create_meter_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Measurements.create_meter_reading(@invalid_attrs)
    end

    test "update_meter_reading/2 with valid data updates the meter_reading" do
      meter_reading = meter_reading_fixture()
      assert {:ok, %MeterReading{} = meter_reading} = Measurements.update_meter_reading(meter_reading, @update_attrs)
      assert meter_reading.absolute_value == 456.7
      assert meter_reading.asset_id == 43
      assert meter_reading.asset_type == "some updated asset_type"
      assert meter_reading.cumulative_value == 456.7
      assert meter_reading.recorded_date_time == ~N[2011-05-18 15:01:01]
      assert meter_reading.site_id == 43
      assert meter_reading.unit_of_measurement == "some updated unit_of_measurement"
      assert meter_reading.work_order_id == 43
    end

    test "update_meter_reading/2 with invalid data returns error changeset" do
      meter_reading = meter_reading_fixture()
      assert {:error, %Ecto.Changeset{}} = Measurements.update_meter_reading(meter_reading, @invalid_attrs)
      assert meter_reading == Measurements.get_meter_reading!(meter_reading.id)
    end

    test "delete_meter_reading/1 deletes the meter_reading" do
      meter_reading = meter_reading_fixture()
      assert {:ok, %MeterReading{}} = Measurements.delete_meter_reading(meter_reading)
      assert_raise Ecto.NoResultsError, fn -> Measurements.get_meter_reading!(meter_reading.id) end
    end

    test "change_meter_reading/1 returns a meter_reading changeset" do
      meter_reading = meter_reading_fixture()
      assert %Ecto.Changeset{} = Measurements.change_meter_reading(meter_reading)
    end
  end
end

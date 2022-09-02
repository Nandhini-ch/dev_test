defmodule Inconn2Service.Measurements.MeterReading do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meter_readings" do
    field :site_id, :integer
    field :asset_id, :integer
    field :asset_type, :string
    field :recorded_date_time, :naive_datetime
    field :absolute_value, :float
    field :cumulative_value, :float
    field :unit_of_measurement, :string
    field :work_order_id, :integer
    field :meter_type, :string

    timestamps()
  end

  @doc false
  def changeset(meter_reading, attrs) do
    meter_reading
    |> cast(attrs, [:site_id, :asset_id, :asset_type, :recorded_date_time, :unit_of_measurement, :absolute_value, :cumulative_value, :work_order_id, :meter_type])
    |> validate_required([:site_id, :asset_id, :asset_type, :recorded_date_time, :unit_of_measurement, :absolute_value, :cumulative_value, :work_order_id, :meter_type])
    |> validate_inclusion(:asset_type, ["L", "E"])
    |> validate_inclusion(:meter_type, ["E", "F", "W"])
  end
end

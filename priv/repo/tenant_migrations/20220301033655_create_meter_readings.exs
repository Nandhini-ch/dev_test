defmodule Inconn2Service.Repo.Migrations.CreateMeterReadings do
  use Ecto.Migration

  def change do
    create table(:meter_readings) do
      add :site_id, :integer
      add :asset_id, :integer
      add :asset_type, :string
      add :recorded_date_time, :naive_datetime
      add :unit_of_measurement, :string
      add :absolute_value, :float
      add :cumulative_value, :float
      add :work_order_id, :integer

      timestamps()
    end

  end
end

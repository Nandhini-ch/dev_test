defmodule Inconn2Service.Repo.Migrations.AddFieldsRegardingDashboards do
  use Ecto.Migration

  def change do
    alter table("workorder_tasks") do
      add :date_time, :naive_datetime
    end

    alter table("meter_readings") do
      add :meter_type, :string
    end


  end

end

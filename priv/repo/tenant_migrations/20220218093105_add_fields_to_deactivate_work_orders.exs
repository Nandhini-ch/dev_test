defmodule Inconn2Service.Repo.Migrations.AddFieldsToDeactivateWorkOrders do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :is_deactivated, :boolean, null: false, default: false
      add :deactivated_date_time, :naive_datetime
    end
  end
end

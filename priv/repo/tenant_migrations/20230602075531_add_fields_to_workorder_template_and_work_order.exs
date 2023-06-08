defmodule Inconn2Service.Repo.Migrations.AddFieldsToWorkorderTemplateAndWorkOrder do
  use Ecto.Migration

  def change do
    alter table("workorder_templates") do
      add :movable, :boolean, default: false
    end

    alter table("work_orders") do
      add :scheduled_end_date, :date
      add :scheduled_end_time, :time
    end
  end
end

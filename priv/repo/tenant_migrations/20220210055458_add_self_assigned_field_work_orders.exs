defmodule Inconn2Service.Repo.Migrations.AddSelfAssignedFieldWorkOrders do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :is_self_assigned, :boolean, null: false, default: false
    end
  end
end

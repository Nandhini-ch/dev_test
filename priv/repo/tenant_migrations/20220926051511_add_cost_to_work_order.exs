defmodule Inconn2Service.Repo.Migrations.AddCostToWorkOrder do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :cost, :float
    end
  end
end

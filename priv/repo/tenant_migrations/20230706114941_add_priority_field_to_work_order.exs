defmodule Inconn2Service.Repo.Migrations.AddPriorityFieldToWorkOrder do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :priority, :string
    end

  end
end

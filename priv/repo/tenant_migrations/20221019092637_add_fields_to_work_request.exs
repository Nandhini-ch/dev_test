defmodule Inconn2Service.Repo.Migrations.AddFieldsToWorkRequest do
  use Ecto.Migration

  def change do
    alter table("work_requests") do
      add :is_workorder_generated, :boolean, default: false
    end
  end
end

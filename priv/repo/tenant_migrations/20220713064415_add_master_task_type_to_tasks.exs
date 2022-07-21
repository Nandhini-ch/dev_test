defmodule Inconn2Service.Repo.Migrations.AddMasterTaskTypeToTasks do
  use Ecto.Migration

  def change do
    alter table("tasks") do
      add :master_task_type_id, :integer
    end
  end
end

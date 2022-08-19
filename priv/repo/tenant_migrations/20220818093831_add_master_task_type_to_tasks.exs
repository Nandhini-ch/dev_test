defmodule Inconn2Service.Repo.Migrations.AddMasterTaskTypeToTasks do
  use Ecto.Migration

  def change do
    alter table("tasks") do
      add :master_task_type_id, :integer
    end

    alter table("task_lists") do
      remove :task_ids
    end
  end
end

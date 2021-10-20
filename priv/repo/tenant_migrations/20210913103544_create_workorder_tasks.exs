defmodule Inconn2Service.Repo.Migrations.CreateWorkorderTasks do
  use Ecto.Migration

  def change do
    create table(:workorder_tasks) do
      add :work_order_id, references(:work_orders, on_delete: :nothing)
      add :task_id, :integer
      add :sequence, :integer
      add :response, :string

      timestamps()
    end

    create index(:workorder_tasks, [:work_order_id])
  end
end

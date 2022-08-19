defmodule Inconn2Service.Repo.Migrations.CreateTaskTasklists do
  use Ecto.Migration

  def change do
    create table(:task_tasklists) do
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :task_list_id, references(:task_lists, on_delete: :delete_all)
      add :sequence, :integer

      timestamps()
    end

    create index(:task_tasklists, [:task_id])
    create index(:task_tasklists, [:task_list_id])
  end
end

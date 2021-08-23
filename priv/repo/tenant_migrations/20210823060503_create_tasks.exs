defmodule Inconn2Service.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :label, :text
      add :task_type, :string
      add :config, :jsonb
      add :estimated_time, :integer

      timestamps()
    end


  end
end

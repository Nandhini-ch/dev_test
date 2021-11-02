defmodule Inconn2Service.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :label, :text
      add :task_type, :string
      add :config, :jsonb
      add :estimated_time, :integer
      add :active, :boolean

      timestamps()
    end


  end
end

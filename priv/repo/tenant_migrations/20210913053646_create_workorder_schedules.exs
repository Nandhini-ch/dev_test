defmodule Inconn2Service.Repo.Migrations.CreateWorkorderSchedules do
  use Ecto.Migration

  def change do
    create table(:workorder_schedules) do
      add :workorder_template_id, references(:workorder_templates, on_delete: :nothing)
      add :asset_id, :integer
      add :user_id, :integer
      add :asset_type, :string
      add :config, :map
      add :next_occurrence_date, :date
      add :next_occurrence_time, :time

      timestamps()
    end
      create index(:workorder_schedules, [:workorder_template_id])

  end
end

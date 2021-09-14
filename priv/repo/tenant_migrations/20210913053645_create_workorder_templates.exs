defmodule Inconn2Service.Repo.Migrations.CreateWorkorderTemplates do
  use Ecto.Migration

  def change do
    create table(:workorder_templates) do
      add :asset_category_id, references(:asset_categories, on_delete: :nothing)
      add :asset_type, :string
      add :name, :string
      add :task_list_id, :integer
      add :tasks, {:array, :map}
      add :estimated_time, :integer
      add :scheduled, :boolean
      add :repeat_every, :integer
      add :repeat_unit, :string
      add :applicable_start, :date
      add :applicable_end, :date
      add :time_start, :time
      add :time_end, :time
      add :create_new, :string
      add :max_times, :integer
      add :workorder_prior_time, :integer
      add :workpermit_required, :boolean
      add :workpermit_check_list_id, :integer
      add :loto_required, :boolean
      add :loto_lock_check_list_id, :integer
      add :loto_release_check_list_id, :integer

      timestamps()
    end
    create index(:workorder_templates, [:asset_category_id])

  end
end

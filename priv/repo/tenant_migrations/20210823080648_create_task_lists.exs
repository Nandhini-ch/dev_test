defmodule Inconn2Service.Repo.Migrations.CreateTaskLists do
  use Ecto.Migration

  def change do
    create table(:task_lists) do
      add :name, :string
      add :task_ids, {:array, :integer}
      add :asset_category_id, references(:asset_categories, on_delete: :nothing)
      add :active, :boolean

      timestamps()
    end
    create index(:task_lists, [:asset_category_id])

  end
end

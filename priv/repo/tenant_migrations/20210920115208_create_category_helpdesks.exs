defmodule Inconn2Service.Repo.Migrations.CreateCategoryHelpdesks do
  use Ecto.Migration

  def change do
    create table(:category_helpdesks) do
      add :user_id, references(:users, on_delete: :nothing)
      add :site_id, references(:sites, on_delete: :nothing)
      add :workrequest_category_id, references(:workrequest_categories, on_delete: :nothing)

      timestamps()
    end

    create index(:category_helpdesks, [:user_id])
    create index(:category_helpdesks, [:site_id])
    create index(:category_helpdesks, [:workrequest_category_id])
  end
end

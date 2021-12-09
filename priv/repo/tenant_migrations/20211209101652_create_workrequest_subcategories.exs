defmodule Inconn2Service.Repo.Migrations.CreateWorkrequestSubcategories do
  use Ecto.Migration

  def change do
    create table(:workrequest_subcategories) do
      add :name, :string
      add :description, :text
      add :workrequest_category_id, references(:workrequest_categories, on_delete: :nothing)

      timestamps()
    end

    create index(:workrequest_subcategories, [:workrequest_category_id])
  end
end

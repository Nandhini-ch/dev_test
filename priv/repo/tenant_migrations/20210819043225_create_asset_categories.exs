defmodule Inconn2Service.Repo.Migrations.CreateAssetCategories do
  use Ecto.Migration

  def change do
    create table(:asset_categories) do
      add :name, :string
      add :asset_type, :string
      add :site_id, references(:sites, on_delete: :nothing)
      timestamps()
      add :path, {:array, :integer}, null: false
    end

      create index(:asset_categories, [:site_id])
  end
end

defmodule Inconn2Service.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :description, :string
      add :location_code, :string
      add :status, :string
      add :qr_code, :uuid, null: false
      add :asset_category_id, references(:asset_categories, on_delete: :nothing)
      add :site_id, references(:sites, on_delete: :nothing)

      timestamps()
      add :path, {:array, :integer}, null: false
      add :active, :boolean
    end


    create unique_index(:locations, [:qr_code])
    create index(:locations, [:site_id])
    create index(:locations, [:asset_category_id])
  end
end

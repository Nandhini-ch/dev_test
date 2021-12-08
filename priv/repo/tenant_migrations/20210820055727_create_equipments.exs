defmodule Inconn2Service.Repo.Migrations.CreateEquipments do
  use Ecto.Migration

  def change do
    create table(:equipments) do
      add :name, :string
      add :equipment_code, :string
      add :asset_category_id, references(:asset_categories, on_delete: :nothing)
      add :site_id, references(:sites, on_delete: :nothing)
      add :location_id, references(:locations, on_delete: :nothing)
      add :connections_in, {:array, :integer}
      add :connections_out, {:array, :integer}
      add :qr_code, :uuid, null: false
      add :active, :boolean


      timestamps()
      add :path, {:array, :integer}, null: false
    end

    create unique_index(:equipments, [:qr_code])
    create index(:equipments, [:site_id])
    create index(:equipments, [:asset_category_id])
    create index(:equipments, [:location_id])
  end
end

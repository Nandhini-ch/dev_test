defmodule Inconn2Service.Repo.Migrations.CreateEquipments do
  use Ecto.Migration

  def change do
    create table(:equipments) do
      add :name, :string
      add :equipment_code, :string
      add :asset_category_id, references(:asset_categories, on_delete: :nothing)
      add :site_id, references(:sites, on_delete: :nothing)
      add :connections_in, {:array, :integer}
      add :connections_out, {:array, :integer}

      timestamps()
      add :path, {:array, :integer}, null: false
    end

    create index(:equipments, [:site_id])
    create index(:equipments, [:asset_category_id])
  end
end

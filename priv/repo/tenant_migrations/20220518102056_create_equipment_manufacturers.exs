defmodule Inconn2Service.Repo.Migrations.CreateEquipmentManufacturers do
  use Ecto.Migration

  def change do
    create table(:equipment_manufacturers) do
      add :name, :string
      add :model_no, :string
      add :serial_no, :string
      add :capacity, :float
      add :unit_of_capacity, :string
      add :year_of_manufacturing, :integer
      add :acquired_date, :date
      add :commissioned_date, :date
      add :purchase_price, :float
      add :depreciation_factor, :float
      add :description, :text
      add :is_warranty_available, :boolean, default: false, null: false
      add :warranty_from, :date
      add :warranty_to, :date
      add :country_of_origin, :string
      add :manufacturer_id, :integer
      add :service_branch_id, :integer
      add :equipment_id, references(:equipments, on_delete: :delete_all)

      timestamps()
    end

    create index(:equipment_manufacturers, [:equipment_id])

  end
end

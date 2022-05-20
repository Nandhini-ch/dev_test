defmodule Inconn2Service.Repo.Migrations.CreateEquipmentMaintenanceVendors do
  use Ecto.Migration

  def change do
    create table(:equipment_maintenance_vendors) do
      add :vendor_scope, :string
      add :is_asset_under_amc, :boolean, default: false, null: false
      add :amc_from, :date
      add :amc_to, :date
      add :amc_frequency, :integer
      add :response_time_in_minutes, :integer
      add :vendor_id, :integer
      add :service_branch_id, :integer
      add :equipment_id, references(:equipments, on_delete: :nothing)

      timestamps()
    end

    create index(:equipment_maintenance_vendors, [:equipment_id])
  end
end

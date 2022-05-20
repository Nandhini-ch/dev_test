defmodule Inconn2Service.Repo.Migrations.CreateEquipmentInsuranceVendors do
  use Ecto.Migration

  def change do
    create table(:equipment_insurance_vendors) do
      add :insurance_policy_no, :string
      add :insurance_scope, :string
      add :start_date, :date
      add :end_date, :date
      add :vendor_id, :integer
      add :service_branch_id, :integer
      add :equipment_id, references(:equipments, on_delete: :nothing)

      timestamps()
    end

    create index(:equipment_insurance_vendors, [:equipment_id])
  end
end

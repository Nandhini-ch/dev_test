defmodule Inconn2Service.Repo.Migrations.AlterFieldsInAssetInfo do
  use Ecto.Migration

  def change do
    alter table("equipment_manufacturers") do
      remove :service_branch_id, :integer
      remove :manufacture_id, :integer
      add :service_branch, :string
      add :manufacture, :string
    end

    alter table("equipment_maintenance_vendors") do
      remove :service_branch_id, :integer
      remove :vendor_id, :integer
      add :service_branch, :string
      add :vendor, :string
    end

    alter table("equipment_insurance_vendors") do
      remove :service_branch_id, :integer
      remove :vendor_id, :integer
      add :service_branch, :string
      add :vendor, :string
    end

    alter table("equipment_dlp_vendors") do
      remove :service_branch_id, :integer
      remove :vendor_id, :integer
      add :service_branch, :string
      add :vendor, :string
    end

  end
end

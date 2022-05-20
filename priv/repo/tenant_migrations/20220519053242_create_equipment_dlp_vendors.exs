defmodule Inconn2Service.Repo.Migrations.CreateEquipmentDlpVendors do
  use Ecto.Migration

  def change do
    create table(:equipment_dlp_vendors) do
      add :vendor_scope, :string
      add :is_asset_under_dlp, :boolean, default: false, null: false
      add :dlp_from, :date
      add :dlp_to, :date
      add :vendor_id, :integer
      add :service_branch_id, :integer
      add :equipment_id, references(:equipments, on_delete: :nothing)

      timestamps()
    end

    create index(:equipment_dlp_vendors, [:equipment_id])
  end
end

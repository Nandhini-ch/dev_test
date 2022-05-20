defmodule Inconn2Service.Repo.Migrations.CreateServiceBranches do
  use Ecto.Migration

  def change do
    create table(:service_branches) do
      add :region, :string
      add :address, :map
      add :contact, :map
      add :manufacturer_id, references(:manufacturers, on_delete: :nothing)
      add :vendor_id, references(:vendors, on_delete: :nothing)

      timestamps()
    end

    create index(:service_branches, [:manufacturer_id])
    create index(:service_branches, [:vendor_id])
  end
end

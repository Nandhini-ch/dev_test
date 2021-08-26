defmodule Inconn2Service.Repo.Migrations.CreateParties do
  use Ecto.Migration

  def change do
    create table(:parties) do
      add :company_name, :string
      add :org_type, :string
      add :allowed_party_type, :string
      add :create_party, :string
      add :contract_start_date, :date
      add :contract_end_date, :date
      add :license_no, :string
      add :licensee, :string
      add :service_id, :id
      add :preferred_service, :string
      add :rates_per_hour, :float
      add :type_of_maintenance, {:array, :string}
      add :address, :jsonb
      add :contact, :jsonb

      timestamps()
    end
  end
end

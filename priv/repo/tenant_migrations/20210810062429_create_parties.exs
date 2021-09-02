defmodule Inconn2Service.Repo.Migrations.CreateParties do
  use Ecto.Migration

  def change do
    create table(:parties) do
      add :company_name, :string
      add :party_type, :string
      add :contract_start_date, :date
      add :contract_end_date, :date
      add :license_no, :string
      add :licensee, :boolean
      add :address, :jsonb
      add :contact, :jsonb

      timestamps()
    end
  end
end

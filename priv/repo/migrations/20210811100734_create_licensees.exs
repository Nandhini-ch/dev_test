defmodule Inconn2Service.Repo.Migrations.CreateLicensees do
  use Ecto.Migration

  def change do
    create table(:licensees) do
      add :company_name, :string
      add :sub_domain, :string
      add :party_type, :string
      add :address, :jsonb
      add :contact, :jsonb
      add :business_type_id, references(:business_types, on_delete: :nothing)

      timestamps()
      add :active, :boolean
    end

    create index(:licensees, [:business_type_id])
    create unique_index(:licensees, [:company_name])
    create unique_index(:licensees, [:sub_domain])
  end
end

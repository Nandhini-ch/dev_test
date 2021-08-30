defmodule Inconn2Service.Repo.Migrations.CreateOrgUnits do
  use Ecto.Migration

  def change do
    create table(:org_units) do
      add :name, :string
      add :party_id, references(:parties, on_delete: :nothing)

      timestamps()
      add :path, {:array, :integer}, null: false
    end
      create index(:org_units, [:party_id])

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateOrgUnits do
  use Ecto.Migration

  def change do
    create table(:org_units) do
      add :name, :string

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.AddPartialUniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:designations, [:name], where: "active = 'true'")
    create unique_index(:roles, [:name], where: "active = 'true'")
    create unique_index(:shifts, [:code], where: "active = 'true'")
    create unique_index(:sites, [:site_code], where: "active = 'true'")
    create unique_index(:locations, [:location_code], where: "active = 'true'")
    create unique_index(:equipments, [:equipment_code], where: "active = 'true'")
    create unique_index(:uoms, [:name], where: "active = 'true'")
  end
end

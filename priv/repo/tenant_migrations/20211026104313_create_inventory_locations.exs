defmodule Inconn2Service.Repo.Migrations.CreateInventoryLocations do
  use Ecto.Migration

  def change do
    create table(:inventory_locations) do
      add :name, :string
      add :description, :text
      add :site_id, :integer
      add :site_location_id, :integer

      timestamps()
    end

  end
end

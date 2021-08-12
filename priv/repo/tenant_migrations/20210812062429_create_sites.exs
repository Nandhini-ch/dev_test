defmodule Inconn2Service.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :description, :string
      add :branch, :string
      add :area, :float
      add :lattitude, :float
      add :longitiude, :float
      add :fencing_radius, :float
      add :site_code, :string
      add :address, :jsonb
      add :contact, :jsonb

      timestamps()
    end

  end
end

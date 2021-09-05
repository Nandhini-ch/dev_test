defmodule Inconn2Service.Repo.Migrations.CreateSites do
  use Ecto.Migration
  alias Inconn2Service.AssetConfig.Party

  def change do
    create table(:sites) do
      add :name, :string
      add :description, :string
      add :branch, :string
      add :area, :float
      add :latitude, :float
      add :longitude, :float
      add :fencing_radius, :float
      add :site_code, :string
      add :party_id, references(:parties, on_delete: :nothing)
      add :address, :jsonb
      add :contact, :jsonb


      timestamps()
    end

  end
end

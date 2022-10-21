defmodule Inconn2Service.Repo.Migrations.CreateZones do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :name, :string
      add :description, :string
      add :path, {:array, :integer}, null: false

      timestamps()
    end

  end
end

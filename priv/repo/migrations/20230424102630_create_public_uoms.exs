defmodule Inconn2Service.Repo.Migrations.CreatePublicUoms do
  use Ecto.Migration

  def change do
    create table(:public_uoms) do
      add :uom_category, :string
      add :uom_unit, :string
      add :description, :string

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateUnitOfMeasurements do
  use Ecto.Migration

  def change do
    create table(:unit_of_measurements) do
      add :name, :string
      add :unit, :string
      add :uom_category_id, references(:uom_categories, on_delete: :delete_all)

      timestamps()
    end

    create index(:unit_of_measurements, [:uom_category_id])
  end
end

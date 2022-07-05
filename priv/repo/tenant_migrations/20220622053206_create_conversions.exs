defmodule Inconn2Service.Repo.Migrations.CreateConversions do
  use Ecto.Migration

  def change do
    create table(:conversions) do
      add :from_unit_of_measurement_id, :integer
      add :to_unit_of_measurement_id, :integer
      add :uom_category_id, :integer
      add :multiplication_factor, :float
      add :active, :boolean, default: true

      timestamps()
    end

  end
end

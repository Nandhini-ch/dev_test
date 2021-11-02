defmodule Inconn2Service.Repo.Migrations.CreateUomConversions do
  use Ecto.Migration

  def change do
    create table(:uom_conversions) do
      add :from_uom_id, :integer
      add :to_uom_id, :integer
      add :mult_factor, :float
      add :inverse_factor, :float

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateUomCategories do
  use Ecto.Migration

  def change do
    create table(:uom_categories) do
      add :name, :string
      add :description, :text

      timestamps()
    end

  end
end

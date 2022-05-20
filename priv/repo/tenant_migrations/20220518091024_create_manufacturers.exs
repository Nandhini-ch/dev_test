defmodule Inconn2Service.Repo.Migrations.CreateManufacturers do
  use Ecto.Migration

  def change do
    create table(:manufacturers) do
      add :name, :string
      add :register_no, :string
      add :description, :text
      add :contact, :map

      timestamps()
    end

  end
end

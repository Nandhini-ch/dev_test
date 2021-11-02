defmodule Inconn2Service.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
      add :name, :string
      add :description, :text
      add :contact, :jsonb
      timestamps()
    end

  end
end

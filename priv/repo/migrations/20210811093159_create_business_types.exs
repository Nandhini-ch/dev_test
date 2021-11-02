defmodule Inconn2Service.Repo.Migrations.CreateBusinessTypes do
  use Ecto.Migration

  def change do
    create table(:business_types) do
      add :name, :string
      add :description, :string
      add :active, :boolean

      timestamps()
    end

  end
end

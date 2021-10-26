defmodule Inconn2Service.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def change do
    create table(:features) do
      add :name, :string
      add :code, :string
      add :description, :string

      timestamps()
    end

    create unique_index(:features, [:name])
    create unique_index(:features, [:code])
  end
end

defmodule Inconn2Service.Repo.Migrations.CreateCustomFields do
  use Ecto.Migration

  def change do
    create table(:custom_fields) do
      add :entity, :string
      add :fields, {:array, :map}

      timestamps()
    end
    create unique_index(:custom_fields, [:entity])
  end
end

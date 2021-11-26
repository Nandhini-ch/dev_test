defmodule Inconn2Service.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def change do
    create table(:features) do
      add :name, :string
      add :code, :string
      add :module_id, references(:modules, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:features, [:name])
    create unique_index(:features, [:code])
    create index(:features, [:module_id])
  end
end

defmodule Inconn2Service.Repo.Migrations.CreateModules do
  use Ecto.Migration

  def change do
    create table(:modules) do
      add :name, :string
      add :description, :string
      add :feature_ids, {:array, :integer}

      timestamps()
    end

    create unique_index(:modules, [:name])
  end
end

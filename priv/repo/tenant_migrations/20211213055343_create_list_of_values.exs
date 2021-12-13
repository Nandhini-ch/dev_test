defmodule Inconn2Service.Repo.Migrations.CreateListOfValues do
  use Ecto.Migration

  def change do
    create table(:list_of_values) do
      add :name, :string
      add :values, {:array, :string}

      timestamps()
    end

  end
end

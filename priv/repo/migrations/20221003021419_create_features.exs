defmodule Inconn2Service.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def change do
    create table(:features) do
      add :name, :string
      add :code, :string

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateUoms do
  use Ecto.Migration

  def change do
    create table(:uoms) do
      add :name, :string
      add :symbol, :string

      timestamps()
    end

  end
end

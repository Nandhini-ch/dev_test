defmodule Inconn2Service.Repo.Migrations.CreateBusinessTypes do
  use Ecto.Migration

  def change do
    create table(:business_types) do
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :code, :string
      add :name, :string

      timestamps()
    end

  end
end

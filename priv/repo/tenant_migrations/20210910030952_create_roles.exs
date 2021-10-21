defmodule Inconn2Service.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :code, :string
      add :name, :string
      add :active, :boolean

      timestamps()
    end

  end
end

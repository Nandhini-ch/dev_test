defmodule Inconn2Service.Repo.Migrations.CreateMasterTaskTypes do
  use Ecto.Migration

  def change do
    create table(:master_task_types) do
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end

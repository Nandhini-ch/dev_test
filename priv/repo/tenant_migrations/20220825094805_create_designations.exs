defmodule Inconn2Service.Repo.Migrations.CreateDesignations do
  use Ecto.Migration

  def change do
    create table(:designations) do
      add :name, :string
      add :description, :string
      add :active, :boolean
      timestamps()
    end

    alter table("employees") do
      add :designation_id, :integer
    end
  end
end

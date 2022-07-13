defmodule Inconn2Service.Repo.Migrations.CreateCheckTypes do
  use Ecto.Migration

  def change do
    create table(:check_types) do
      add :name, :string
      add :description, :text
      add :active, :boolean, default: true

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateWidgets do
  use Ecto.Migration

  def change do
    create table(:widgets) do
      add :code, :string
      add :description, :string
      add :title, :string

      timestamps()
    end

  end
end

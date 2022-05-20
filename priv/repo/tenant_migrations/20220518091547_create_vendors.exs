defmodule Inconn2Service.Repo.Migrations.CreateVendors do
  use Ecto.Migration

  def change do
    create table(:vendors) do
      add :name, :string
      add :description, :text
      add :register_no, :string
      add :contact, :map

      timestamps()
    end

  end
end

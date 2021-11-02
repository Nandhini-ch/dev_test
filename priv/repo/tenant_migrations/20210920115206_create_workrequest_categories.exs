defmodule Inconn2Service.Repo.Migrations.CreateWorkrequestCategories do
  use Ecto.Migration

  def change do
    create table(:workrequest_categories) do
      add :name, :string
      add :description, :string
      add :active, :boolean, default: true

      timestamps()
    end

  end
end

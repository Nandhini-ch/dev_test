defmodule Inconn2Service.Repo.Migrations.CreateWorkrequestCategories do
  use Ecto.Migration

  def change do
    create table(:workrequest_categories) do
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end

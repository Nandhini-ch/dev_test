defmodule Inconn2Service.Repo.Migrations.CreateAssetCategories do
  use Ecto.Migration

  def change do
    create table(:asset_categories) do
      add :name, :string
      add :asset_type, :string
      timestamps()
      add :path, {:array, :integer}, null: false
    end

  end
end

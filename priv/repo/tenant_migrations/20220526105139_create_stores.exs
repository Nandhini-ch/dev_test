defmodule Inconn2Service.Repo.Migrations.CreateStores do
  use Ecto.Migration

  def change do
    create table(:stores) do
      add :name, :string
      add :description, :text
      add :location_id, :integer
      add :aisle_count, :integer
      add :aisle_notation, :string
      add :row_count, :integer
      add :row_notation, :string
      add :bin_count, :integer
      add :bin_notation, :string
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps()
    end

    create index(:stores, [:site_id])
  end
end

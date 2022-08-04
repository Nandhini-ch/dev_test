defmodule Inconn2Service.Repo.Migrations.CreateScopes do
  use Ecto.Migration

  def change do
    create table(:scopes) do
      add :is_applicable_to_all_location, :boolean, default: false, null: false
      add :location_ids, {:array, :integer}
      add :is_applicable_to_all_asset_category, :boolean, default: false, null: false
      add :asset_category_ids, {:array, :integer}
      add :contract_id, references(:contracts, on_delete: :nothing)
      add :site_id, references(:sites, on_delete: :nothing)
      add :start_date, :date
      add :end_date, :date

      timestamps()
    end

    create index(:scopes, [:contract_id])
    create index(:scopes, [:site_id])
  end
end

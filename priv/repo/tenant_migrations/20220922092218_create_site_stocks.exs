defmodule Inconn2Service.Repo.Migrations.CreateSiteStocks do
  use Ecto.Migration

  def change do
    create table(:site_stocks) do
      add :quantity, :float
      add :is_msl_breached, :string, default: "NO"
      add :breached_date_time, :naive_datetime
      add :site_id, references(:sites, on_delete: :nothing)
      add :inventory_item_id, references(:inventory_items, on_delete: :nothing)
      add :unit_of_measurement_id, references(:unit_of_measurements, on_delete: :nothing)

      timestamps()
    end

    create index(:site_stocks, [:site_id])
    create index(:site_stocks, [:inventory_item_id])
    create index(:site_stocks, [:unit_of_measurement_id])
  end
end

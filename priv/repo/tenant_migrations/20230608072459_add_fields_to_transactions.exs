defmodule Inconn2Service.Repo.Migrations.AddFieldsToTransactions do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add :total_stock, :float
      add :is_minimum_stock_level_breached, :boolean
      add :minimum_stock_level, :float
    end
  end
end

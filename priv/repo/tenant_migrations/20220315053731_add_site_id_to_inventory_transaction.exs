defmodule Inconn2Service.Repo.Migrations.AddSiteIdToInventoryTransaction do
  use Ecto.Migration

  def change do
    alter table("inventory_transactions") do
      add :site_id, :integer
    end
  end
end

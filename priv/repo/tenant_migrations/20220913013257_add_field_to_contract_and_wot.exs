defmodule Inconn2Service.Repo.Migrations.AddFieldToContractAndWot do
  use Ecto.Migration

  def change do
    alter table("contracts") do
      add :contract_type, :string
    end

    alter table("workorder_templates") do
      add :amc, :boolean, default: false
    end
  end
end

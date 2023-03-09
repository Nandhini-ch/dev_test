defmodule Inconn2Service.Repo.Migrations.AddActiveFieldToUom do
  use Ecto.Migration

  def change do
    alter table("uoms") do
      add :active, :boolean
    end
  end
end

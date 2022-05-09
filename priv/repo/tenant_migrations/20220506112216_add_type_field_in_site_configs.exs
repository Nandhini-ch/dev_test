defmodule Inconn2Service.Repo.Migrations.AddTypeFieldInSiteConfig do
  use Ecto.Migration

  def change do
    alter table("site_config") do
      add :type, :string
    end
  end
end

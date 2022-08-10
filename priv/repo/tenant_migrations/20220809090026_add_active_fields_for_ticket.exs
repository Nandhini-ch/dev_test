defmodule Inconn2Service.Repo.Migrations.AddActiveFieldsForTicket do
  use Ecto.Migration

  def change do
    alter table("workrequest_subcategories")  do
      add :active, :boolean, default: true
    end

    alter table("category_helpdesks")  do
      add :active, :boolean, default: true
    end
  end
end

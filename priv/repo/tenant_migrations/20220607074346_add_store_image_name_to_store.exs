defmodule Inconn2Service.Repo.Migrations.AddStoreImageNameToStore do
  use Ecto.Migration

  def change do
    alter table("stores") do
      add :store_image_name, :string
    end
  end
end

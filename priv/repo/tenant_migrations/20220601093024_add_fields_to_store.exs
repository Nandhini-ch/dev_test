defmodule Inconn2Service.Repo.Migrations.AddFieldsToStore do
  use Ecto.Migration

  def change do
    alter table("stores") do
      add :store_image_type, :string
    end
  end
end

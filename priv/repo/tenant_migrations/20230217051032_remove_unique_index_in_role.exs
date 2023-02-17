defmodule Inconn2Service.Repo.Migrations.RemoveUniqueIndexInRole do
  use Ecto.Migration

  def change do
    alter table("roles") do
      drop_if_exists index("roles", [:name]), mode: :unique
    end
  end
end

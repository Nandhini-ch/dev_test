defmodule Inconn2Service.Repo.Migrations.RemoveUniqueIndexInRole do
  use Ecto.Migration

  def change do
      drop index("roles", [:name])
  end
end

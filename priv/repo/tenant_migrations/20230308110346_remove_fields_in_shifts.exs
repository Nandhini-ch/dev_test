defmodule Inconn2Service.Repo.Migrations.RemoveFieldsInShifts do
  use Ecto.Migration

  def change do
    drop_if_exists index("shifts", [:name])
  end
end

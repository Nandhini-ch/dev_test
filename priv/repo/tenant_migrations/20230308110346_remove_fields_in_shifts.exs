defmodule Inconn2Service.Repo.Migrations.RemoveFieldsInShifts do
  use Ecto.Migration

  def change do
    drop index("shifts", [:name])
  end
end

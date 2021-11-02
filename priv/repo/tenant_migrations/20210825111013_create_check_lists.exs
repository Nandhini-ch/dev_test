defmodule Inconn2Service.Repo.Migrations.CreateCheckLists do
  use Ecto.Migration

  def change do
    create table(:check_lists) do
      add :name, :string
      add :type, :string
      add :check_ids, {:array, :integer}
      add :active, :boolean

      timestamps()
    end

  end
end

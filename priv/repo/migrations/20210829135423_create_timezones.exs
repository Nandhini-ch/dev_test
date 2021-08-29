defmodule Inconn2Service.Repo.Migrations.CreateTimezones do
  use Ecto.Migration

  def change do
    create table(:timezones) do
      add :label, :string
      add :continent, :string
      add :state, :string
      add :city, :string
      add :utc_offset_text, :string
      add :utc_offset_seconds, :integer

      timestamps()
    end

  end
end

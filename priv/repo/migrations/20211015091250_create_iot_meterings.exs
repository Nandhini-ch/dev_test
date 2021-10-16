defmodule Inconn2Service.Repo.Migrations.CreateIotMeterings do
  use Ecto.Migration

  def change do
    create table(:iot_meterings) do
      add :equipment_readings, :json
      add :processed, :boolean, default: false, null: false

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateWorkSchedulers do
  use Ecto.Migration

  def change do
    create table(:work_schedulers) do
      add :prefix, :string
      add :workorder_schedule_id, :integer
      add :zone, :string
      add :utc_date_time, :utc_datetime

      timestamps()
    end
  end
end

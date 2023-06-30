defmodule Inconn2Service.Repo.Migrations.CreateWorkRequestCloseSchedulers do
  use Ecto.Migration

  def change do
    create table(:work_request_close_schedulers) do
      add :work_request_id, :integer
      add :prefix, :string
      add :utc_date_time, :utc_datetime
      add :time_zone, :string

      timestamps()
    end

  end
end

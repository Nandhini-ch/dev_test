defmodule Inconn2Service.Repo.Migrations.AddRaisedDateTimeToWorkRequest do
  use Ecto.Migration

  def change do
    alter table("work_requests") do
      add :raised_date_time, :naive_datetime
    end
  end
end

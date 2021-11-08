defmodule Inconn2Service.Repo.Migrations.CreateWorkOrders do
  use Ecto.Migration

  def change do
    create table(:work_orders) do
      add :site_id, :integer
      add :asset_id, :integer
      add :user_id, :integer
      add :type, :string
      add :created_date, :date
      add :created_time, :time
      add :assigned_date, :date
      add :assigned_time, :time
      add :scheduled_date, :date
      add :scheduled_time, :time
      add :start_date, :date
      add :start_time, :time
      add :completed_date, :date
      add :completed_time, :time
      add :status, :string
      add :workorder_template_id, :integer
      add :workorder_schedule_id, :integer
      add :work_request_id, :integer

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateBankholidays do
  use Ecto.Migration

  def change do
    create table(:bankholidays) do
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :site_id, references(:sites, on_delete: :nothing)

      timestamps()
    end

    create index(:bankholidays, [:site_id, :start_date, :end_date],name: :index_holidays_dates)
  end
end

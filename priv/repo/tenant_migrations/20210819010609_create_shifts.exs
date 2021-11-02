defmodule Inconn2Service.Repo.Migrations.CreateShifts do
  use Ecto.Migration
  #alias Inconn2Service.AssetConfig.Sites

  def change do
    create table(:shifts) do
      add :name, :string
      add :start_time, :time
      add :end_time, :time
      add :applicable_days, {:array, :integer}
      add :start_date, :date
      add :end_date, :date
      add :site_id, references(:sites, on_delete: :nothing)

      timestamps()
      add :active, :boolean
    end

    #create index(:shifts, [:site_id])

    create unique_index(:shifts, [:site_id, :start_date, :end_date, :start_time, :end_time, :applicable_days], name: :index_shifts_dates)
  end
end

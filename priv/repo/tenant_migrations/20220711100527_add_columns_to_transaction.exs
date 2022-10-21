defmodule Inconn2Service.Repo.Migrations.AddColumnsToTransaction do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add :transaction_date, :date
      add :transaction_time, :time
      add :dc_no, :string
      add :dc_file, :binary
    end
  end
end

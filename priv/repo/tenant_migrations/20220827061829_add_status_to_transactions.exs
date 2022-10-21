defmodule Inconn2Service.Repo.Migrations.AddStatusToTransactions do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add :status, :string
    end
  end
end

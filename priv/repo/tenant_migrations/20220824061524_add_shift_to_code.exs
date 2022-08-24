defmodule Inconn2Service.Repo.Migrations.AddShiftToCode do
  use Ecto.Migration

  def change do
    alter table("shifts") do
      add :code, :string
    end

  end
end

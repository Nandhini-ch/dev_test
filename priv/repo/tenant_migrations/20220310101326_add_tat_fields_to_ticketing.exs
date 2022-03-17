defmodule Inconn2Service.Repo.Migrations.AddTatFieldsToWorkrequestSubcategory do
  use Ecto.Migration

  def change do
    alter table("workrequest_subcategories") do
      add :response_tat, :integer
      add :resolution_tat, :integer
    end

    alter table("work_requests") do
      add :response_tat, :integer
      add :resolution_tat, :integer
    end
  end
end

defmodule Inconn2Service.Repo.Migrations.CreateWorkRequests do
  use Ecto.Migration

  def change do
    create table(:work_requests) do
      add :site_id, references(:sites, on_delete: :nothing)
      add :workrequest_category_id, references(:workrequest_categories, on_delete: :nothing)
      add :asset_ids, {:array, :integer}
      add :description, :string
      add :priority, :string
      add :request_type, :string
      add :date_of_requirement, :date
      add :time_of_requirement, :time
      add :requested_user_id, :integer
      add :assigned_user_id, :integer
      add :attachment, :binary
      add :attachment_type, :string
      add :approvals_required, {:array, :integer}
      add :approved_user_ids, {:array, :integer}
      add :rejected_user_ids, {:array, :integer}
      add :status, :string
      add :is_migration_required, :boolean

      timestamps()
    end
      create index(:work_requests, [:site_id])
      create index(:work_requests, [:workrequest_category_id])
  end
end

defmodule Inconn2Service.Repo.Migrations.CreateWorkrequestFeedbacks do
  use Ecto.Migration

  def change do
    create table(:workrequest_feedbacks) do
      add :work_request_id, :integer
      add :user_id, :integer
      add :email, :string
      add :site_id, :integer
      add :rating, :integer

      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
      add :name, :string
      add :description, :text
      add :nature_of_business, :string
      add :registration_no, :string
      add :gst_no, :string
      add :website, :string
      add :currency_uom_id, :integer
      add :remarks, :text
      add :contact, :jsonb
      timestamps()
    end

  end
end

defmodule Inconn2Service.Repo.Migrations.CreateInventorySuppliers do
  use Ecto.Migration

  def change do
    create table(:inventory_suppliers) do
      add :name, :string
      add :description, :text
      add :business_type, :string
      add :website, :string
      add :gst_no, :string
      add :reference_no, :string
      add :contact_person, :string
      add :contact_no, :string
      add :escalation1_contact_name, :string
      add :escalation2_contact_name, :string
      add :escalation1_contact_no, :string
      add :escalation2_contact_no, :string

      timestamps()
    end

  end
end

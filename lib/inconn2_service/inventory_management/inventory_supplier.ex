defmodule Inconn2Service.InventoryManagement.InventorySupplier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_suppliers" do
    field :business_type, :string
    field :contact_no, :string
    field :contact_person, :string
    field :description, :string
    field :escalation1_contact_name, :string
    field :escalation1_contact_no, :string
    field :escalation2_contact_name, :string
    field :escalation2_contact_no, :string
    field :gst_no, :string
    field :supplier_code, :string
    field :name, :string
    field :reference_no, :string
    field :website, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(inventory_supplier, attrs) do
    inventory_supplier
    |> cast(attrs, [:name, :description, :supplier_code, :business_type, :website, :gst_no, :reference_no, :contact_person, :contact_no, :escalation1_contact_name, :escalation2_contact_name, :escalation1_contact_no, :escalation2_contact_no, :active])
    |> validate_required([:name, :business_type, :contact_person, :contact_no, :escalation1_contact_name, :escalation1_contact_no])
  end
end

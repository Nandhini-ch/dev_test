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
    field :name, :string
    field :reference_no, :string
    field :website, :string

    timestamps()
  end

  @doc false
  def changeset(inventory_supplier, attrs) do
    inventory_supplier
    |> cast(attrs, [:name, :description, :business_type, :website, :gst_no, :reference_no, :contact_person, :contact_no, :escalation1_contact_name, :escalation2_contact_name, :escalation1_contact_no, :escalation2_contact_no])
    |> validate_required([:name, :business_type, :gst_no, :reference_no, :contact_person, :contact_no, :escalation1_contact_name, :escalation1_contact_no])
  end
end

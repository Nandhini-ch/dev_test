defmodule Inconn2Service.Inventory.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Common.{ContactEmbed}

  schema "suppliers" do
    field :name, :string
    field :description, :string
    field :nature_of_business, :string
    field :registration_no, :string
    field :gst_no, :string
    field :website, :string
    field :remarks, :string
    embeds_one :contact, ContactEmbed, on_replace: :delete
    has_many :supplier_items, Inconn2Service.Inventory.SupplierItem

    timestamps()
  end

  @doc false
  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:name, :description, :nature_of_business, :registration_no, :gst_no, :website, :remarks])
    |> validate_required([:name, :nature_of_business, :registration_no, :gst_no])
    |> cast_embed(:contact)
  end
end

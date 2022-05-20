defmodule Inconn2Service.AssetInfo.Vendor do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Common.ContactEmbed
  alias Inconn2Service.AssetInfo.ServiceBranch

  schema "vendors" do
    field :description, :string
    field :name, :string
    field :register_no, :string
    embeds_one :contact, ContactEmbed, on_replace: :delete
    has_many :service_branches, ServiceBranch

    timestamps()
  end

  @doc false
  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [:name, :description, :register_no])
    |> validate_required([:name])
    |> cast_embed(:contact)
  end
end

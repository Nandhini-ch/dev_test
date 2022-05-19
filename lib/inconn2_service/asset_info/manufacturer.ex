defmodule Inconn2Service.AssetInfo.Manufacturer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Common.ContactEmbed
  alias Inconn2Service.AssetInfo.ServiceBranch

  schema "manufacturers" do
    field :description, :string
    field :name, :string
    field :register_no, :string
    embeds_one :contact, ContactEmbed, on_replace: :delete
    has_many :service_branches, ServiceBranch

    timestamps()
  end

  @doc false
  def changeset(manufacturer, attrs) do
    manufacturer
    |> cast(attrs, [:name, :register_no, :description])
    |> validate_required([:name, :register_no, :description])
    |> cast_embed(:contact)
  end
end

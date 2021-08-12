defmodule Inconn2Service.Account.Licensee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Account.BusinessType
  alias Inconn2Service.Common.{AddressEmbed, ContactEmbed}

  schema "licensees" do
    field :company_name, :string
    field :sub_domain, :string
    embeds_one :address, AddressEmbed, on_replace: :delete
    embeds_one :contact, ContactEmbed, on_replace: :delete
    belongs_to :business_type, BusinessType

    timestamps()
  end

  @doc false
  def changeset(licensee, attrs) do
    licensee
    |> cast(attrs, [:company_name, :business_type_id, :sub_domain])
    |> validate_required([:company_name, :business_type_id, :sub_domain])
    |> unique_constraint(:company_name)
    |> unique_constraint(:sub_domain)
    |> assoc_constraint(:business_type)
    |> cast_embed(:address)
    |> cast_embed(:contact)
  end
end

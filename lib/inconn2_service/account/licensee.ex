defmodule Inconn2Service.Account.Licensee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Account.BusinessType
  alias Inconn2Service.Common.{AddressEmbed, ContactEmbed}

  schema "licensees" do
    field :company_name, :string
    field :sub_domain, :string
    # possible values for party_type [AO,SELF,SP]
    # if party_type is [AO, SELF] then other_party_type is nil
    # if party_type is [AO, SP] then other_party_type is SP
    # if party_type is [SP, AO] then other_party_type is AO
    field :party_type, :string
    field :active, :boolean, default: true
    embeds_one :address, AddressEmbed, on_replace: :delete
    embeds_one :contact, ContactEmbed, on_replace: :delete
    belongs_to :business_type, BusinessType

    timestamps()
  end

  @doc false
  def changeset(licensee, attrs) do
    licensee
    |> cast(attrs, [:company_name, :business_type_id, :sub_domain, :party_type])
    |> validate_required([:company_name, :business_type_id, :sub_domain, :party_type])
    |> unique_constraint(:company_name)
    |> unique_constraint(:sub_domain)
    |> validate_inclusion(:party_type, ["AO", "SP"])
    |> assoc_constraint(:business_type)
    |> cast_embed(:address)
    |> cast_embed(:contact)
  end
end

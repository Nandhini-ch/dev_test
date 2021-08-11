defmodule Inconn2Service.Account.AddressEmbed do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :address_line1, :string
    field :address_line2, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :postcode, :string
  end

  def changeset(address_embed, attrs) do
    address_embed
    |> cast(attrs, [:address_line1, :address_line2, :city, :state, :country, :postcode])
    |> validate_required([:address_line1, :address_line2, :city, :state, :country, :postcode])
  end
end

defmodule Inconn2Service.AssetConfig.Party do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parties" do
    field :company_name, :string
    # Org type is either asset owner or service provider
    field :party_type, :string, default: "AO"
    field :contract_end_date, :date
    field :contract_start_date, :date
    field :license_no, :string
    field :licensee, :boolean, default: false
    embeds_one :address, AddressEmbed, on_replace: :delete
    embeds_one :contact, ContactEmbed, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(party, attrs) do
    party
    |> cast(attrs, [
      :company_name,
      :party_type,
      :contract_start_date,
      :contract_end_date,
      :licensee,
      :license_no
    ])
    |> validate_required([
      :company_name,
      :party_type,
      :licensee
    ])
    |> check_party_type()
    |> cast_embed(:address)
    |> cast_embed(:contact)
  end

  defp check_party_type(changeset) do
    party_type = get_field(changeset, :party_type)

    case party_type do
      "SP" ->
        changeset

      "AO" ->
        changeset

      _ ->
        add_error(
          changeset,
          :party_type,
          "ORG party type is not within [AO, SP]"
        )
    end
  end
end

defmodule Inconn2Service.AssetConfig.Party do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parties" do
    field :company_name, :string
    # Org type is either asset owner or service provider
    field :org_type, :string, default: "AO"
    field :allowed_party_type, :string, default: "SELF"
    field :create_party, :string, default: "N"
    field :contract_end_date, :date
    field :contract_start_date, :date
    field :license_no, :string
    field :licensee, :string, default: "N"
    field :service_id, :id
    field :preferred_service, :string, default: "N"
    field :rates_per_hour, :float

    # preventive maintenance, planned maintenance, predictive maintenance, condition-based maintenance
    # Usual amc service provider may be different for adhoc requests servicing partners
    field :type_of_maintenance, {:array, :string}, default: ["PLANM", "PREVM"]
    embeds_one :address, AddressEmbed, on_replace: :delete
    embeds_one :contact, ContactEmbed, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(party, attrs) do
    party
    |> cast(attrs, [
      :company_name,
      :org_type,
      :allowed_party_type,
      :create_party,
      :contract_start_date,
      :contract_end_date,
      :licensee,
      :license_no,
      :service_id,
      :preferred_service,
      :rates_per_hour,
      :type_of_maintenance
    ])
    |> validate_required([
      :company_name,
      :org_type,
      :allowed_party_type,
      :create_party,
      :licensee,
      :service_id,
      :preferred_service,
      :type_of_maintenance
    ])
    |> check_allowed_party_type()
    |> check_org_type()
    |> cast_embed(:address)
    |> cast_embed(:contact)
  end

  defp check_allowed_party_type(changeset) do
    allowed_party_type = get_field(changeset, :allowed_party_type)

    case allowed_party_type do
      "SELF" ->
        changeset

      "SP" ->
        changeset

      "AO" ->
        changeset

      _ ->
        add_error(
          changeset,
          :allowed_party_type,
          "Allowed party type is not within [SELF, AO, SP]"
        )
    end
  end

  defp check_org_type(changeset) do
    org_type = get_field(changeset, :org_type)

    case org_type do
      "SP" ->
        changeset

      "AO" ->
        changeset

      _ ->
        add_error(
          changeset,
          :org_type,
          "ORG party type is not within [AO, SP]"
        )
    end
  end
end

defmodule Inconn2Service.AssetInfo.ServiceBranch do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Common.ContactEmbed
  alias Inconn2Service.Common.AddressEmbed

  schema "service_branches" do
    field :region, :string
    field :manufacturer_id, :integer
    field :vendor_id, :integer
    embeds_one :contact, ContactEmbed, on_replace: :delete
    embeds_one :address, AddressEmbed, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(service_branch, attrs) do
    service_branch
    |> cast(attrs, [:region, :manufacturer_id, :vendor_id])
    |> validate_required([:region])
    |> cast_embed(:address)
    |> cast_embed(:contact)
  end

  def validate_vendor_manufacturer_id(cs) do
    cond do
      is_nil(get_field(cs, :manufacturer_id, nil)) and is_nil(get_field(cs, :vendor_id, nil)) ->
        add_error(cs, :manufacturer_id, "Either manufacturer or vendor should be present")
        |> add_error(:vendor_id, "Either manufacturer or vendor should be present")

      not is_nil(get_field(cs, :manufacturer_id, nil)) and not is_nil(get_field(cs, :vendor_id, nil)) ->
        add_error(cs, :manufacturer_id, "Both manufacturer and vendor cannot be present")
        |> add_error(:vendor_id, "Both manufacturer or vendor cannot be present")

      true ->
        cs
    end
  end
end

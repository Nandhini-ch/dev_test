defmodule Inconn2Service.AssetConfig.Site do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Common.{AddressEmbed, ContactEmbed}
  alias Inconn2Service.AssetConfig.Party

  schema "sites" do
    field :area, :float
    field :branch, :string
    field :description, :string
    field :lattitude, :float
    field :longitiude, :float
    field :name, :string
    field :fencing_radius, :float
    field :site_code, :string
    belongs_to :party, Party
    embeds_one :address, AddressEmbed, on_replace: :delete
    embeds_one :contact, ContactEmbed, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [
      :name,
      :description,
      :branch,
      :area,
      :lattitude,
      :longitiude,
      :fencing_radius,
      :site_code,
      :party_id
    ])
    |> validate_required([:name, :description, :site_code])
    |> cast_embed(:address)
    |> cast_embed(:contact)
    |> assoc_constraint(:party)
  end
end

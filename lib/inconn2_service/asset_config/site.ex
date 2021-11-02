defmodule Inconn2Service.AssetConfig.Site do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Common.{AddressEmbed, ContactEmbed}
  alias Inconn2Service.AssetConfig.Party

  schema "sites" do
    field :area, :float
    field :branch, :string
    field :description, :string
    field :latitude, :float
    field :longitude, :float
    field :name, :string
    field :fencing_radius, :float
    field :site_code, :string
    field :time_zone, :string
    field :active, :boolean, default: true
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
      :latitude,
      :longitude,
      :fencing_radius,
      :site_code,
      :party_id,
      :time_zone,
      :active
    ])
    |> validate_required([:name, :description, :site_code, :party_id, :time_zone])
    |> cast_embed(:address)
    |> cast_embed(:contact)
    |> assoc_constraint(:party)
  end
end

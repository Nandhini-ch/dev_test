defmodule Inconn2Service.AssetManagement.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :area, :float
    field :branch, :string
    field :description, :string
    field :lattitude, :float
    field :longitiude, :float
    field :name, :string
    field :radius, :float
    field :site_code, :string
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
      :radius,
      :site_code
    ])
    |> validate_required([:name, :description, :site_code])
    |> cast_embed(:address)
    |> cast_embed(:contact)
  end
end

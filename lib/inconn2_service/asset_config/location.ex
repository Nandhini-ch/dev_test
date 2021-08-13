defmodule Inconn2Service.AssetConfig.Location do
  use Ecto.Schema

  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site

  schema "locations" do
    field :location_code, :string
    field :description, :string
    field :name, :string
    belongs_to :site, Site
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :description, :location_code, :site_id, :parent_id])
    |> validate_required([:name, :location_code, :site_id])
    |> assoc_constraint(:site)
  end
end

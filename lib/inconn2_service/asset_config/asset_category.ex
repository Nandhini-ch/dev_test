defmodule Inconn2Service.AssetConfig.AssetCategory do
  use Ecto.Schema
  alias Inconn2Service.AssetConfig.Site

  import Ecto.Changeset

  schema "asset_categories" do
    field :name, :string
    field :asset_type, :string
    field :parent_id, :integer, virtual: true ,default: 0
    field :path, {:array, :integer}, default: []
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(asset_category, attrs) do
    asset_category
    |> cast(attrs, [:name, :asset_type, :site_id, :parent_id])
    |> validate_required([:name, :site_id])
    |> validate_inclusion(:asset_type, ["L", "E"] )
    |> validate_asset_type()
  end
  
  def validate_asset_type(changeset) do
    pid = get_field(changeset, :parent_id)
    if pid == 0 do
      validate_required(changeset, :asset_type)
    else
      changeset
    end
  end


end

defmodule Inconn2Service.AssetConfig.AssetCategory do
  use Ecto.Schema

  import Ecto.Changeset

  schema "asset_categories" do
    field :name, :string
    field :asset_type, :string
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(asset_category, attrs) do
    asset_category
    |> cast(attrs, [:name, :asset_type, :parent_id], :active)
    |> validate_required([:name])
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

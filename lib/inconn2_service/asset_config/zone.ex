defmodule Inconn2Service.AssetConfig.Zone do
  use Ecto.Schema
  import Ecto.Changeset

  schema "zones" do
    field :description, :string
    field :name, :string
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []

    timestamps()
  end

  @doc false
  def changeset(zone, attrs) do
    zone
    |> cast(attrs, [:name, :description, :path, :parent_id])
    |> validate_required([:name, :path])
  end
end

defmodule Inconn2Service.Staff.OrgUnit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.AssetConfig.Party

  schema "org_units" do
    field :name, :string
    belongs_to :party, Party
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []
    field :active, :boolean, default: true
    timestamps()
  end

  @doc false
  def changeset(org_unit, attrs) do
    org_unit
    |> cast(attrs, [:name, :party_id, :parent_id])
    |> validate_required([:name, :party_id])
    |> assoc_constraint(:party)
  end
end

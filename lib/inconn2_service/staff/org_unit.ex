defmodule Inconn2Service.Staff.OrgUnit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "org_units" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(org_unit, attrs) do
    org_unit
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

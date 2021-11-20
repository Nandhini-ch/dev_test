defmodule Inconn2Service.Staff.Module do
  use Ecto.Schema
  import Ecto.Changeset

  schema "modules" do
    field :name, :string
    field :description, :string
    field :feature_ids, {:array, :integer}

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
    |> cast(attrs, [:name, :description, :feature_ids])
    |> validate_required([:name, :feature_ids])
    |> unique_constraint(:name)
  end
end

defmodule Inconn2Service.CheckListConfig.Check do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checks" do
    field :label, :string
    field :type, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(check, attrs) do
    check
    |> cast(attrs, [:label, :type, :active])
    |> validate_required([:label, :type])
    |> validate_inclusion(:type, ["WP", "LOTO"])
  end
end

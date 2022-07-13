defmodule Inconn2Service.CheckListConfig.CheckType do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.CheckListConfig.Check

  schema "check_types" do
    field :description, :string
    field :name, :string
    field :active, :boolean, default: true
    has_many :checks, Check

    timestamps()
  end

  @doc false
  def changeset(check_type, attrs) do
    check_type
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name])
  end
end

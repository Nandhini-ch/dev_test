defmodule Inconn2Service.CheckListConfig.Check do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.CheckListConfig.CheckType

  schema "checks" do
    field :label, :string
    # field :type, :string
    # field :check_type_id, :integer
    belongs_to :check_type, CheckType
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(check, attrs) do
    check
    |> cast(attrs, [:label, :check_type_id, :active])
    |> validate_required([:label, :check_type_id])
  end
end

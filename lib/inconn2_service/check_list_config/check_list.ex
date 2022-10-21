defmodule Inconn2Service.CheckListConfig.CheckList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "check_lists" do
    field :name, :string
    field :type, :string
    field :check_ids, {:array, :integer}
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(check_list, attrs) do
    check_list
    |> cast(attrs, [:name, :type, :check_ids, :active])
    |> validate_required([:name, :type, :check_ids])
    |> validate_inclusion(:type, ["PRE", "WP", "LOTO"])
  end

end

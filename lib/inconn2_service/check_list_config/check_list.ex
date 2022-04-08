defmodule Inconn2Service.CheckListConfig.CheckList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "check_lists" do
    field :name, :string
    field :type, :string
    field :check_ids, {:array, :integer}
    field :site_id, :integer
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(check_list, attrs) do
    check_list
    |> cast(attrs, [:name, :type, :check_ids, :active, :site_id])
    |> validate_required([:name, :type, :check_ids])
    |> validate_inclusion(:type, ["PRE", "WP", "LOTO"])
    |> validate_site_id()
  end

  defp validate_site_id(cs) do
    type = get_field(cs, :type, nil)
    if type != nil do
      case type do
        "PRE" ->
          validate_required(cs, [:site_id])

        _ ->
          cs
      end
    else
      cs
    end
  end
end

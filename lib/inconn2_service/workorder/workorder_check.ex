defmodule Inconn2Service.Workorder.WorkorderCheck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workorder_checks" do
    field :approved, :boolean, default: false
    field :check_id, :integer
    field :type, :string
    belongs_to :work_order, Inconn2Service.Workorder.WorkOrder

    timestamps()
  end

  @doc false
  def changeset(workorder_check, attrs) do
    workorder_check
    |> cast(attrs, [:check_id, :type, :approved, :work_order_id])
    |> validate_required([:check_id, :type, :work_order_id])
    |> validate_inclusion(:type, ["PRE", "WP", "LOTO"])
    # |> validate_remarks()
    |> assoc_constraint(:work_order)
  end

  # defp validate_remarks(cs) do
  #   approved = get_field(cs, :approved, nil)
  #   if approved != nil do
  #     case approved do
  #       false ->
  #         validate_required(cs, [:remarks])

  #       _ ->
  #         cs
  #     end
  #   else
  #     cs
  #   end
  # end
end

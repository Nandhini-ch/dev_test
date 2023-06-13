defmodule Inconn2Service.Sla do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sla" do
    field :category, :string
    field :criteria, :string
    field :calculation, :string
    field :kpi, :string
    field :type, :string
    field :weightage, :integer
    field :range_list, {:array, :map}, default: []
    field :boolean_list, {:array, :map}, default: []
    field :count_list, {:array, :map}, default: []
    field :approver, :integer
    field :active, :boolean, default: true
    field :contract_id, :integer
    field :cycle, :string
    field :exception, :boolean, default: false
    field :exception_value, :integer
    field :justification, :string

    timestamps()
  end

  @doc false
  def changeset(sla, attrs) do
    sla
    |> cast(attrs, [
      :category,
      :criteria,
      :calculation,
      :kpi,
      :type,
      :weightage,
      :range_list,
      :boolean_list,
      :count_list,
      :approver,
      :active,
      :contract_id,
      :cycle,
      :exception,
      :exception_value,
      :justification
    ])
    |> validate_required([:category, :criteria, :type, :weightage, :approver])
    |> validate_inclusion(:category, ["asset", "maintenance", "inventory", "people", "ticketing", "manual"])
  end
end

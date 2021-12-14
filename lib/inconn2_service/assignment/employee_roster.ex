defmodule Inconn2Service.Assignment.EmployeeRoster do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.Employee

  schema "employee_rosters" do
    belongs_to :employee, Employee
    belongs_to :site, Inconn2Service.AssetConfig.Site
    belongs_to :shift, Inconn2Service.Settings.Shift
    field :start_date, :date
    field :end_date, :date
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(employee_roster, attrs) do
    employee_roster
    |> cast(attrs, [:employee_id, :site_id, :shift_id, :start_date, :end_date, :active])
    |> validate_required([:employee_id, :shift_id, :start_date, :end_date])
    |> validate_date_order()
    |> assoc_constraint(:employee)
    |> assoc_constraint(:site)
    |> assoc_constraint(:shift)
  end

  defp validate_date_order(cs) do
    start_date = get_field(cs, :start_date)
    end_date = get_field(cs, :end_date)
    case Date.compare(start_date, end_date) do
      :gt -> add_error(cs, :start_date, "cannot be later than 'end_date'")
      _ -> cs
    end
  end
end

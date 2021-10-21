defmodule Inconn2Service.Assignment.EmployeeRoster do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employee_rosters" do
    field :employee_id, :integer
    field :site_id, :integer
    field :shift_id, :integer
    field :start_date, :date
    field :end_date, :date
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(employee_roster, attrs) do
    employee_roster
    |> cast(attrs, [:employee_id, :site_id, :shift_id, :start_date, :end_date])
    |> validate_required([:employee_id, :site_id, :shift_id, :start_date, :end_date])
    |> validate_date_order()
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

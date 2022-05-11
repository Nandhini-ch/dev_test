defmodule Inconn2Service.Assignment.ManualAttendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "manual_attendances" do
    field :in_time_marked_by, :integer
    field :out_time_marked_by, :integer
    field :employee_id, :integer
    field :shift_id, :integer
    field :in_time, :naive_datetime
    field :is_overtime, :boolean, default: false
    field :out_time, :naive_datetime
    field :overtime_hours_in_minutes, :float
    field :status, :string
    field :worked_hours_in_minutes, :float

    timestamps()
  end

  @doc false
  def changeset(manual_attendance, attrs) do
    manual_attendance
    |> cast(attrs, [:shift_id, :employee_id, :in_time, :out_time, :worked_hours_in_minutes, :is_overtime, :overtime_hours_in_minutes, :in_time_marked_by, :out_time_marked_by, :status])
    |> validate_required([:shift_id, :employee_id, :in_time])
    |> validate_inclusion(:status, ["PT", "AB", "LT"])
    |> validate_out_time()
    |> validate_ot_required()
  end

  defp validate_out_time(cs) do
    out_time = get_field(cs, :out_time)
    in_time = get_field(cs, :in_time)
    if in_time != nil and out_time != nil do
      case NaiveDateTime.compare(in_time, out_time) do
        :lt -> cs
        _ -> add_error(cs, :out_time, "should be greater than in_time")
      end
    else
      cs
    end
  end

  defp validate_ot_required(cs) do
    case get_field(cs, :out_time) do
      nil -> cs
       _ -> validate_required(cs, [:is_overtime])
    end
  end

end

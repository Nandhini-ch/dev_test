defmodule Inconn2Service.Assignment.Attendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendances" do
    field :shift_id, :integer
    field :date, :date
    field :attendance_record, {:array, :map}

    timestamps()
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:shift_id, :date, :attendance_record])
    |> validate_required([:shift_id, :date, :attendance_record])
    |> validate_attendance_params()
  end

  defp validate_attendance_params(cs) do
    attendance_record = get_field(cs, :attendance_record, nil)
    if attendance_record != nil do
      employee_ids = Enum.map(attendance_record, fn x -> x["employee_id"] end)
      presents = Enum.map(attendance_record, fn x -> x["present"] end)
      if nil in employee_ids or nil in presents do
        add_error(cs, :attendance, "is invalid")
      else
        validate_present(cs, presents)
      end
    else
      cs
    end
  end

  defp validate_present(cs, presents) do
    presents = Enum.map(presents, fn x -> x in ["YES", "NO"] end)
    if false in presents do
      add_error(cs, :attendance, "is invalid")
    else
      cs
    end
  end
end

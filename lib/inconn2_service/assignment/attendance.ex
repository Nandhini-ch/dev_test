defmodule Inconn2Service.Assignment.Attendance do
  use Ecto.Schema
  import Ecto.Changeset
  # alias Inconn2Service.Settings.Shift

  schema "attendances" do
    field :date_time, :naive_datetime
    field :latitude, :float
    field :longitude, :float
    field :site_id, :integer
    field :employee_id, :integer

    timestamps()
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:date_time, :latitude, :longitude, :site_id, :employee_id])
    |> validate_required([:date_time, :latitude, :longitude])
    # |> validate_attendance_params()
    # |> assoc_constraint(:shift)
  end

  # defp validate_attendance_params(cs) do
  #   attendance_record = get_field(cs, :attendance_record, nil)
  #   if attendance_record != nil do
  #     employee_ids = Enum.map(attendance_record, fn x -> x["employee_id"] end)
  #     presents = Enum.map(attendance_record, fn x -> x["present"] end)
  #     if nil in employee_ids or nil in presents do
  #       add_error(cs, :attendance, "is invalid")
  #     else
  #       validate_present(cs, presents)
  #     end
  #   else
  #     cs
  #   end
  # end

  # defp validate_present(cs, presents) do
  #   presents = Enum.map(presents, fn x -> x in ["YES", "NO"] end)
  #   if false in presents do
  #     add_error(cs, :attendance, "is invalid")
  #   else
  #     cs
  #   end
  # end
end

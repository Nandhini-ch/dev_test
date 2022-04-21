defmodule Inconn2Service.Assignment.AttendanceFailureLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendance_failure_logs" do
    field :date_time, :naive_datetime
    field :employee_id, :integer
    field :failure_image, :binary

    timestamps()
  end

  @doc false
  def changeset(attendance_failure_log, attrs) do
    attendance_failure_log
    |> cast(attrs, [:employee_id, :failure_image, :date_time])
    |> validate_required([:employee_id, :failure_image, :date_time])
  end
end

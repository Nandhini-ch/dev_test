defmodule Inconn2Service.Assignment.Attendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendances" do
    field :latitude, :float
    field :longitude, :float
    field :site_id, :integer
    field :employee_id, :integer
    field :in_time, :naive_datetime
    field :out_time, :naive_datetime
    field :shift_id, :integer
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:in_time, :out_time, :latitude, :longitude, :site_id, :employee_id, :shift_id, :status])
    |> validate_required([:site_id, :employee_id, :in_time])
    |> validate_inclusion(:status , ["ONTM", "LATE", "HFDY"])
  end

end

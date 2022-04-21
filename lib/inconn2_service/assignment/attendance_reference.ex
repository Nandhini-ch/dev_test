defmodule Inconn2Service.Assignment.AttendanceReference do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendance_references" do
    field :employee_id, :integer
    field :reference_image, :binary
    field :status, :string, default: "AP"

    timestamps()
  end

  @doc false
  def changeset(attendance_reference, attrs) do
    attendance_reference
    |> cast(attrs, [:employee_id, :reference_image, :status])
    |> validate_required([:employee_id, :reference_image])
    |> validate_inclusion(:status, ["AP", "NA"])
  end
end

defmodule Inconn2Service.Common.IotMetering do
  use Ecto.Schema
  import Ecto.Changeset

  schema "iot_meterings" do
    field :equipment_readings, :map
    field :processed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(iot_metering, attrs) do
    iot_metering
    |> cast(attrs, [:equipment_readings, :processed])
    |> validate_required([:equipment_readings])
  end
end

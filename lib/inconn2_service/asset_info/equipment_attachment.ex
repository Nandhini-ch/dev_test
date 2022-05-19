defmodule Inconn2Service.AssetInfo.EquipmentAttachment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "equipment_attachments" do
    field :attachment, :binary
    field :attachment_type, :string
    field :name, :string
    field :equipment_id, :id

    timestamps()
  end

  @doc false
  def changeset(equipment_attachment, attrs) do
    equipment_attachment
    |> cast(attrs, [:name, :attachment, :attachment_type])
    |> validate_required([:name, :attachment, :attachment_type])
  end
end

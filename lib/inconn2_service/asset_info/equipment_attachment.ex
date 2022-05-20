defmodule Inconn2Service.AssetInfo.EquipmentAttachment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Equipment

  schema "equipment_attachments" do
    field :attachment, :binary
    field :attachment_type, :string
    field :name, :string
    belongs_to :equipment, Equipment

    timestamps()
  end

  @doc false
  def changeset(equipment_attachment, attrs) do
    equipment_attachment
    |> cast(attrs, [:name, :attachment, :attachment_type, :equipment_id])
    |> validate_required([:name, :attachment, :attachment_type, :equipment_id])
  end
end

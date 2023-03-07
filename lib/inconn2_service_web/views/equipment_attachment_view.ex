defmodule Inconn2ServiceWeb.EquipmentAttachmentView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.EquipmentAttachmentView

  def render("index.json", %{equipment_attachments: equipment_attachments}) do
    %{data: render_many(equipment_attachments, EquipmentAttachmentView, "equipment_attachment.json")}
  end

  def render("show.json", %{equipment_attachment: equipment_attachment}) do
    %{data: render_one(equipment_attachment, EquipmentAttachmentView, "equipment_attachment.json")}
  end

  def render("equipment_attachment.json", %{equipment_attachment: equipment_attachment}) do
    %{id: equipment_attachment.id,
      name: equipment_attachment.name,
      file_size: equipment_attachment.file_size,
      attachment_type: equipment_attachment.attachment_type}
  end
end

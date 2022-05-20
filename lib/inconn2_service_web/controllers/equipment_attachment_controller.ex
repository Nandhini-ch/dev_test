defmodule Inconn2ServiceWeb.EquipmentAttachmentController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentAttachment

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    equipment_attachments = AssetInfo.list_equipment_attachments(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_attachments: equipment_attachments)
  end

  def list_for_equipment(conn, %{"equipment_id" => equipment_id}) do
    equipment_attachments = AssetInfo.list_equipment_attachments_for_equipment(equipment_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", equipment_attachments: equipment_attachments)
  end


  def create(conn, %{"equipment_attachment" => equipment_attachment_params}) do
    with {:ok, %EquipmentAttachment{} = equipment_attachment} <- AssetInfo.create_equipment_attachment(equipment_attachment_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.equipment_attachment_path(conn, :show, equipment_attachment))
      |> render("show.json", equipment_attachment: equipment_attachment)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment_attachment = AssetInfo.get_equipment_attachment!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", equipment_attachment: equipment_attachment)
  end

  def update(conn, %{"id" => id, "equipment_attachment" => equipment_attachment_params}) do
    equipment_attachment = AssetInfo.get_equipment_attachment!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentAttachment{} = equipment_attachment} <- AssetInfo.update_equipment_attachment(equipment_attachment, equipment_attachment_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", equipment_attachment: equipment_attachment)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment_attachment = AssetInfo.get_equipment_attachment!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EquipmentAttachment{}} <- AssetInfo.delete_equipment_attachment(equipment_attachment, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def get_attachment(conn, %{"id" => id}) do
    equipment_attachment = AssetInfo.get_equipment_attachment!(id, conn.assigns.sub_domain_prefix)
    case equipment_attachment.attachment do
      nil ->
        {:error, :not_found}
      binary ->
        conn
        |> put_resp_content_type(equipment_attachment.attachment_type)
        |> send_resp(200, binary)
    end
  end
end

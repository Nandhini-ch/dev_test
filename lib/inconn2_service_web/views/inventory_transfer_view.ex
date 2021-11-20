defmodule Inconn2ServiceWeb.InventoryTransferView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.InventoryTransferView

  def render("index.json", %{inventory_transfers: inventory_transfers}) do
    %{data: render_many(inventory_transfers, InventoryTransferView, "inventory_transfer.json")}
  end

  def render("show.json", %{inventory_transfer: inventory_transfer}) do
    %{data: render_one(inventory_transfer, InventoryTransferView, "inventory_transfer.json")}
  end

  def render("inventory_transfer.json", %{inventory_transfer: inventory_transfer}) do
    %{id: inventory_transfer.id,
      from_location_id: inventory_transfer.from_location_id,
      to_location_id: inventory_transfer.to_location_id,
      uom_id: inventory_transfer.uom_id,
      quantity: inventory_transfer.quantity,
      reference: inventory_transfer.reference,
      remarks: inventory_transfer.remarks}
  end
end

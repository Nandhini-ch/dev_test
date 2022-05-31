defmodule Inconn2ServiceWeb.InventorySupplierView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.InventorySupplierView

  def render("index.json", %{inventory_suppliers: inventory_suppliers}) do
    %{data: render_many(inventory_suppliers, InventorySupplierView, "inventory_supplier.json")}
  end

  def render("show.json", %{inventory_supplier: inventory_supplier}) do
    %{data: render_one(inventory_supplier, InventorySupplierView, "inventory_supplier.json")}
  end

  def render("inventory_supplier.json", %{inventory_supplier: inventory_supplier}) do
    %{id: inventory_supplier.id,
      name: inventory_supplier.name,
      supplier_code: inventory_supplier.supplier_code,
      description: inventory_supplier.description,
      business_type: inventory_supplier.business_type,
      website: inventory_supplier.website,
      gst_no: inventory_supplier.gst_no,
      reference_no: inventory_supplier.reference_no,
      contact_person: inventory_supplier.contact_person,
      contact_no: inventory_supplier.contact_no,
      escalation1_contact_name: inventory_supplier.escalation1_contact_name,
      escalation2_contact_name: inventory_supplier.escalation2_contact_name,
      escalation1_contact_no: inventory_supplier.escalation1_contact_no,
      escalation2_contact_no: inventory_supplier.escalation2_contact_no}
  end
end

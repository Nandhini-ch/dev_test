defmodule Inconn2Service.AssetInfo do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.AssetInfo.Manufacturer
  # alias Inconn2Service.AssetConfig.Equipment

  def list_manufacturers(prefix) do
    Repo.all(Manufacturer, prefix: prefix)
  end

  def get_manufacturer!(id, prefix), do: Repo.get!(Manufacturer, id, prefix: prefix)

  def create_manufacturer(attrs \\ %{}, prefix) do
    %Manufacturer{}
    |> Manufacturer.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_manufacturer(%Manufacturer{} = manufacturer, attrs, prefix) do
    manufacturer
    |> Manufacturer.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_manufacturer(%Manufacturer{} = manufacturer, prefix) do
    Repo.delete(manufacturer, prefix: prefix)
  end

  def change_manufacturer(%Manufacturer{} = manufacturer, attrs \\ %{}) do
    Manufacturer.changeset(manufacturer, attrs)
  end

  alias Inconn2Service.AssetInfo.Vendor

  def list_vendors(prefix) do
    Repo.all(Vendor, prefix: prefix)
  end

  def get_vendor!(id, prefix), do: Repo.get!(Vendor, id, prefix: prefix)


  def create_vendor(attrs \\ %{}, prefix) do
    %Vendor{}
    |> Vendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_vendor(%Vendor{} = vendor, attrs, prefix) do
    vendor
    |> Vendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_vendor(%Vendor{} = vendor, prefix) do
    Repo.delete(vendor, prefix: prefix)
  end

  def change_vendor(%Vendor{} = vendor, attrs \\ %{}) do
    Vendor.changeset(vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.ServiceBranch

  def list_service_branches(prefix) do
    Repo.all(ServiceBranch, prefix: prefix)
  end

  def list_service_branches_by_vendor_id(vendor_id, prefix) do
    from(sb in ServiceBranch, where: sb.vendor_id == ^vendor_id)
    |> Repo.all(prefix: prefix)
  end

  def list_service_branches_by_manufacturer_id(manufacturer_id, prefix) do
    from(sb in ServiceBranch, where: sb.manufacturer_id == ^manufacturer_id)
    |> Repo.all(prefix: prefix)
  end

  def get_service_branch!(id, prefix), do: Repo.get!(ServiceBranch, id, prefix: prefix)

  def create_service_branch(attrs \\ %{}, prefix) do
    %ServiceBranch{}
    |> ServiceBranch.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_service_branch(%ServiceBranch{} = service_branch, attrs, prefix) do
    service_branch
    |> ServiceBranch.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_service_branch(%ServiceBranch{} = service_branch, prefix) do
    Repo.delete(service_branch, prefix: prefix)
  end

  def change_service_branch(%ServiceBranch{} = service_branch, attrs \\ %{}) do
    ServiceBranch.changeset(service_branch, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentManufacturer

  def list_equipment_manufacturers(prefix) do
    Repo.all(EquipmentManufacturer, prefix: prefix)
  end

  def list_equipment_manufacturers_by_equipment_id(equipment_id, prefix) do
    from(em in EquipmentManufacturer, where: em.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  def get_equipment_manufacturer!(id, prefix), do: Repo.get!(EquipmentManufacturer, id, prefix: prefix)

  def create_equipment_manufacturer(attrs \\ %{}, prefix) do
    %EquipmentManufacturer{}
    |> EquipmentManufacturer.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_equipment_manufacturer(%EquipmentManufacturer{} = equipment_manufacturer, attrs, prefix) do
    equipment_manufacturer
    |> EquipmentManufacturer.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_equipment_manufacturer(%EquipmentManufacturer{} = equipment_manufacturer, prefix) do
    Repo.delete(equipment_manufacturer, prefix: prefix)
  end

  def change_equipment_manufacturer(%EquipmentManufacturer{} = equipment_manufacturer, attrs \\ %{}) do
    EquipmentManufacturer.changeset(equipment_manufacturer, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentDlpVendor

  def list_equipment_dlp_vendors(prefix) do
    Repo.all(EquipmentDlpVendor, prefix: prefix)
  end

  def list_equipment_dlp_vendors_by_equipment_id(equipment_id, prefix) do
    from(edv in EquipmentDlpVendor, where: edv.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  def get_equipment_dlp_vendor!(id, prefix), do: Repo.get!(EquipmentDlpVendor, id, prefix: prefix)

  def create_equipment_dlp_vendor(attrs \\ %{}, prefix) do
    %EquipmentDlpVendor{}
    |> EquipmentDlpVendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_equipment_dlp_vendor(%EquipmentDlpVendor{} = equipment_dlp_vendor, attrs, prefix) do
    equipment_dlp_vendor
    |> EquipmentDlpVendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_equipment_dlp_vendor(%EquipmentDlpVendor{} = equipment_dlp_vendor, prefix) do
    Repo.delete(equipment_dlp_vendor, prefix: prefix)
  end

  def change_equipment_dlp_vendor(%EquipmentDlpVendor{} = equipment_dlp_vendor, attrs \\ %{}) do
    EquipmentDlpVendor.changeset(equipment_dlp_vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentMaintenanceVendor

  def list_equipment_maintenance_vendors(prefix) do
    Repo.all(EquipmentMaintenanceVendor, prefix: prefix)
  end

  def list_equipment_maintenance_vendors_by_equipment_id(equipment_id, prefix) do
    from(emv in EquipmentMaintenanceVendor, where: emv.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  def get_equipment_maintenance_vendor!(id, prefix), do: Repo.get!(EquipmentMaintenanceVendor, id, prefix: prefix)

  def create_equipment_maintenance_vendor(attrs \\ %{}, prefix) do
    %EquipmentMaintenanceVendor{}
    |> EquipmentMaintenanceVendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_equipment_maintenance_vendor(%EquipmentMaintenanceVendor{} = equipment_maintenance_vendor, attrs, prefix) do
    equipment_maintenance_vendor
    |> EquipmentMaintenanceVendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_equipment_maintenance_vendor(%EquipmentMaintenanceVendor{} = equipment_maintenance_vendor, prefix) do
    Repo.delete(equipment_maintenance_vendor, prefix: prefix)
  end

  def change_equipment_maintenance_vendor(%EquipmentMaintenanceVendor{} = equipment_maintenance_vendor, attrs \\ %{}) do
    EquipmentMaintenanceVendor.changeset(equipment_maintenance_vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentInsuranceVendor

  def list_equipment_insurance_vendors(prefix) do
    Repo.all(EquipmentInsuranceVendor, prefix: prefix)
  end

  def list_equipment_insurance_vendors_by_equipment_id(equipment_id, prefix) do
    from(eiv in EquipmentInsuranceVendor, where: eiv.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  def get_equipment_insurance_vendor!(id, prefix), do: Repo.get!(EquipmentInsuranceVendor, id, prefix: prefix)

  def create_equipment_insurance_vendor(attrs \\ %{}, prefix) do
    %EquipmentInsuranceVendor{}
    |> EquipmentInsuranceVendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_equipment_insurance_vendor(%EquipmentInsuranceVendor{} = equipment_insurance_vendor, attrs, prefix) do
    equipment_insurance_vendor
    |> EquipmentInsuranceVendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_equipment_insurance_vendor(%EquipmentInsuranceVendor{} = equipment_insurance_vendor, prefix) do
    Repo.delete(equipment_insurance_vendor, prefix: prefix)
  end

  def change_equipment_insurance_vendor(%EquipmentInsuranceVendor{} = equipment_insurance_vendor, attrs \\ %{}) do
    EquipmentInsuranceVendor.changeset(equipment_insurance_vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentAttachment

  def list_equipment_attachments(prefix) do
    Repo.all(EquipmentAttachment, prefix: prefix)
  end

  def list_equipment_attachments_for_equipment(equipment_id, prefix) do
    from(ea in EquipmentAttachment, where: ea.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  def get_equipment_attachment!(id, prefix), do: Repo.get!(EquipmentAttachment, id, prefix: prefix)

  def create_equipment_attachment(attrs \\ %{}, prefix) do
    attrs = read_attachment(attrs)
    %EquipmentAttachment{}
    |> EquipmentAttachment.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  defp read_attachment(attrs) do
    attachment = Map.get(attrs, "attachment")
    if attachment != nil and attachment != "" do
      {:ok, %{size: size}} = File.stat(attachment.path)
      {:ok, attachment_binary} = File.read(attachment.path)
      attachment_type = attachment.content_type
      attrs
      |> Map.put("attachment", attachment_binary)
      |> Map.put("file_size", size)
      |> Map.put("attachment_type", attachment_type)
    else
      attrs
    end
  end

  def update_equipment_attachment(%EquipmentAttachment{} = equipment_attachment, attrs, prefix) do
    equipment_attachment
    |> EquipmentAttachment.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_equipment_attachment(%EquipmentAttachment{} = equipment_attachment, prefix) do
    Repo.delete(equipment_attachment, prefix: prefix)
  end

  def change_equipment_attachment(%EquipmentAttachment{} = equipment_attachment, attrs \\ %{}) do
    EquipmentAttachment.changeset(equipment_attachment, attrs)
  end
end

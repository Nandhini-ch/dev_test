defmodule Inconn2Service.AssetInfo do
  @moduledoc """
  The AssetInfo context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.AssetInfo.Manufacturer
  alias Inconn2Service.AssetConfig.Equipment

  @doc """
  Returns the list of manufacturers.

  ## Examples

      iex> list_manufacturers()
      [%Manufacturer{}, ...]

  """
  def list_manufacturers(prefix) do
    Repo.all(Manufacturer, prefix: prefix)
  end

  @doc """
  Gets a single manufacturer.

  Raises `Ecto.NoResultsError` if the Manufacturer does not exist.

  ## Examples

      iex> get_manufacturer!(123)
      %Manufacturer{}

      iex> get_manufacturer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_manufacturer!(id, prefix), do: Repo.get!(Manufacturer, id, prefix: prefix)

  @doc """
  Creates a manufacturer.

  ## Examples

      iex> create_manufacturer(%{field: value})
      {:ok, %Manufacturer{}}

      iex> create_manufacturer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_manufacturer(attrs \\ %{}, prefix) do
    %Manufacturer{}
    |> Manufacturer.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a manufacturer.

  ## Examples

      iex> update_manufacturer(manufacturer, %{field: new_value})
      {:ok, %Manufacturer{}}

      iex> update_manufacturer(manufacturer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_manufacturer(%Manufacturer{} = manufacturer, attrs, prefix) do
    manufacturer
    |> Manufacturer.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a manufacturer.

  ## Examples

      iex> delete_manufacturer(manufacturer)
      {:ok, %Manufacturer{}}

      iex> delete_manufacturer(manufacturer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_manufacturer(%Manufacturer{} = manufacturer, prefix) do
    Repo.delete(manufacturer, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking manufacturer changes.

  ## Examples

      iex> change_manufacturer(manufacturer)
      %Ecto.Changeset{data: %Manufacturer{}}

  """
  def change_manufacturer(%Manufacturer{} = manufacturer, attrs \\ %{}) do
    Manufacturer.changeset(manufacturer, attrs)
  end

  alias Inconn2Service.AssetInfo.Vendor

  @doc """
  Returns the list of vendors.

  ## Examples

      iex> list_vendors()
      [%Vendor{}, ...]

  """
  def list_vendors(prefix) do
    Repo.all(Vendor, prefix: prefix)
  end

  @doc """
  Gets a single vendor.

  Raises `Ecto.NoResultsError` if the Vendor does not exist.

  ## Examples

      iex> get_vendor!(123)
      %Vendor{}

      iex> get_vendor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vendor!(id, prefix), do: Repo.get!(Vendor, id, prefix: prefix)

  @doc """
  Creates a vendor.

  ## Examples

      iex> create_vendor(%{field: value})
      {:ok, %Vendor{}}

      iex> create_vendor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vendor(attrs \\ %{}, prefix) do
    %Vendor{}
    |> Vendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a vendor.

  ## Examples

      iex> update_vendor(vendor, %{field: new_value})
      {:ok, %Vendor{}}

      iex> update_vendor(vendor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vendor(%Vendor{} = vendor, attrs, prefix) do
    vendor
    |> Vendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a vendor.

  ## Examples

      iex> delete_vendor(vendor)
      {:ok, %Vendor{}}

      iex> delete_vendor(vendor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vendor(%Vendor{} = vendor, prefix) do
    Repo.delete(vendor, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vendor changes.

  ## Examples

      iex> change_vendor(vendor)
      %Ecto.Changeset{data: %Vendor{}}

  """
  def change_vendor(%Vendor{} = vendor, attrs \\ %{}) do
    Vendor.changeset(vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.ServiceBranch

  @doc """
  Returns the list of service_branches.

  ## Examples

      iex> list_service_branches()
      [%ServiceBranch{}, ...]

  """
  def list_service_branches(prefix) do
    Repo.all(ServiceBranch, prefix: prefix)
  end

  @doc """
  Gets a single service_branch.

  Raises `Ecto.NoResultsError` if the Service branch does not exist.

  ## Examples

      iex> get_service_branch!(123)
      %ServiceBranch{}

      iex> get_service_branch!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service_branch!(id, prefix), do: Repo.get!(ServiceBranch, id, prefix: prefix)

  @doc """
  Creates a service_branch.

  ## Examples

      iex> create_service_branch(%{field: value})
      {:ok, %ServiceBranch{}}

      iex> create_service_branch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service_branch(attrs \\ %{}, prefix) do
    %ServiceBranch{}
    |> ServiceBranch.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a service_branch.

  ## Examples

      iex> update_service_branch(service_branch, %{field: new_value})
      {:ok, %ServiceBranch{}}

      iex> update_service_branch(service_branch, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service_branch(%ServiceBranch{} = service_branch, attrs, prefix) do
    service_branch
    |> ServiceBranch.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a service_branch.

  ## Examples

      iex> delete_service_branch(service_branch)
      {:ok, %ServiceBranch{}}

      iex> delete_service_branch(service_branch)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service_branch(%ServiceBranch{} = service_branch, prefix) do
    Repo.delete(service_branch, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service_branch changes.

  ## Examples

      iex> change_service_branch(service_branch)
      %Ecto.Changeset{data: %ServiceBranch{}}

  """
  def change_service_branch(%ServiceBranch{} = service_branch, attrs \\ %{}) do
    ServiceBranch.changeset(service_branch, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentManufacturer

  @doc """
  Returns the list of equipment_manufacturers.

  ## Examples

      iex> list_equipment_manufacturers()
      [%EquipmentManufacturer{}, ...]

  """
  def list_equipment_manufacturers(prefix) do
    Repo.all(EquipmentManufacturer, prefix: prefix)
  end

  def list_equipment_manufacturers_by_equipment_id(equipment_id, prefix) do
    from(em in EquipmentManufacturer, where: em.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single equipment_manufacturer.

  Raises `Ecto.NoResultsError` if the Equipment manufacturer does not exist.

  ## Examples

      iex> get_equipment_manufacturer!(123)
      %EquipmentManufacturer{}

      iex> get_equipment_manufacturer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment_manufacturer!(id, prefix), do: Repo.get!(EquipmentManufacturer, id, prefix: prefix)

  @doc """
  Creates a equipment_manufacturer.

  ## Examples

      iex> create_equipment_manufacturer(%{field: value})
      {:ok, %EquipmentManufacturer{}}

      iex> create_equipment_manufacturer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment_manufacturer(attrs \\ %{}, prefix) do
    %EquipmentManufacturer{}
    |> EquipmentManufacturer.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a equipment_manufacturer.

  ## Examples

      iex> update_equipment_manufacturer(equipment_manufacturer, %{field: new_value})
      {:ok, %EquipmentManufacturer{}}

      iex> update_equipment_manufacturer(equipment_manufacturer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment_manufacturer(%EquipmentManufacturer{} = equipment_manufacturer, attrs, prefix) do
    equipment_manufacturer
    |> EquipmentManufacturer.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a equipment_manufacturer.

  ## Examples

      iex> delete_equipment_manufacturer(equipment_manufacturer)
      {:ok, %EquipmentManufacturer{}}

      iex> delete_equipment_manufacturer(equipment_manufacturer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment_manufacturer(%EquipmentManufacturer{} = equipment_manufacturer, prefix) do
    Repo.delete(equipment_manufacturer, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment_manufacturer changes.

  ## Examples

      iex> change_equipment_manufacturer(equipment_manufacturer)
      %Ecto.Changeset{data: %EquipmentManufacturer{}}

  """
  def change_equipment_manufacturer(%EquipmentManufacturer{} = equipment_manufacturer, attrs \\ %{}) do
    EquipmentManufacturer.changeset(equipment_manufacturer, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentDlpVendor

  @doc """
  Returns the list of equipment_dlp_vendors.

  ## Examples

      iex> list_equipment_dlp_vendors()
      [%EquipmentDlpVendor{}, ...]

  """
  def list_equipment_dlp_vendors(prefix) do
    Repo.all(EquipmentDlpVendor, prefix: prefix)
  end

  def list_equipment_dlp_vendors_by_equipment_id(equipment_id, prefix) do
    from(edv in EquipmentDlpVendor, where: edv.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single equipment_dlp_vendor.

  Raises `Ecto.NoResultsError` if the Equipment dlp vendor does not exist.

  ## Examples

      iex> get_equipment_dlp_vendor!(123)
      %EquipmentDlpVendor{}

      iex> get_equipment_dlp_vendor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment_dlp_vendor!(id, prefix), do: Repo.get!(EquipmentDlpVendor, id, prefix: prefix)

  @doc """
  Creates a equipment_dlp_vendor.

  ## Examples

      iex> create_equipment_dlp_vendor(%{field: value})
      {:ok, %EquipmentDlpVendor{}}

      iex> create_equipment_dlp_vendor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment_dlp_vendor(attrs \\ %{}, prefix) do
    %EquipmentDlpVendor{}
    |> EquipmentDlpVendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a equipment_dlp_vendor.

  ## Examples

      iex> update_equipment_dlp_vendor(equipment_dlp_vendor, %{field: new_value})
      {:ok, %EquipmentDlpVendor{}}

      iex> update_equipment_dlp_vendor(equipment_dlp_vendor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment_dlp_vendor(%EquipmentDlpVendor{} = equipment_dlp_vendor, attrs, prefix) do
    equipment_dlp_vendor
    |> EquipmentDlpVendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a equipment_dlp_vendor.

  ## Examples

      iex> delete_equipment_dlp_vendor(equipment_dlp_vendor)
      {:ok, %EquipmentDlpVendor{}}

      iex> delete_equipment_dlp_vendor(equipment_dlp_vendor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment_dlp_vendor(%EquipmentDlpVendor{} = equipment_dlp_vendor, prefix) do
    Repo.delete(equipment_dlp_vendor, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment_dlp_vendor changes.

  ## Examples

      iex> change_equipment_dlp_vendor(equipment_dlp_vendor)
      %Ecto.Changeset{data: %EquipmentDlpVendor{}}

  """
  def change_equipment_dlp_vendor(%EquipmentDlpVendor{} = equipment_dlp_vendor, attrs \\ %{}) do
    EquipmentDlpVendor.changeset(equipment_dlp_vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentMaintenanceVendor

  @doc """
  Returns the list of equipment_maintenance_vendors.

  ## Examples

      iex> list_equipment_maintenance_vendors()
      [%EquipmentMaintenanceVendor{}, ...]

  """
  def list_equipment_maintenance_vendors(prefix) do
    Repo.all(EquipmentMaintenanceVendor, prefix: prefix)
  end

  def list_equipment_maintenance_vendors_by_equipment_id(equipment_id, prefix) do
    from(emv in EquipmentMaintenanceVendor, where: emv.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single equipment_maintenance_vendor.

  Raises `Ecto.NoResultsError` if the Equipment maintenance vendor does not exist.

  ## Examples

      iex> get_equipment_maintenance_vendor!(123)
      %EquipmentMaintenanceVendor{}

      iex> get_equipment_maintenance_vendor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment_maintenance_vendor!(id, prefix), do: Repo.get!(EquipmentMaintenanceVendor, id, prefix: prefix)

  @doc """
  Creates a equipment_maintenance_vendor.

  ## Examples

      iex> create_equipment_maintenance_vendor(%{field: value})
      {:ok, %EquipmentMaintenanceVendor{}}

      iex> create_equipment_maintenance_vendor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment_maintenance_vendor(attrs \\ %{}, prefix) do
    %EquipmentMaintenanceVendor{}
    |> EquipmentMaintenanceVendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a equipment_maintenance_vendor.

  ## Examples

      iex> update_equipment_maintenance_vendor(equipment_maintenance_vendor, %{field: new_value})
      {:ok, %EquipmentMaintenanceVendor{}}

      iex> update_equipment_maintenance_vendor(equipment_maintenance_vendor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment_maintenance_vendor(%EquipmentMaintenanceVendor{} = equipment_maintenance_vendor, attrs, prefix) do
    equipment_maintenance_vendor
    |> EquipmentMaintenanceVendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a equipment_maintenance_vendor.

  ## Examples

      iex> delete_equipment_maintenance_vendor(equipment_maintenance_vendor)
      {:ok, %EquipmentMaintenanceVendor{}}

      iex> delete_equipment_maintenance_vendor(equipment_maintenance_vendor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment_maintenance_vendor(%EquipmentMaintenanceVendor{} = equipment_maintenance_vendor, prefix) do
    Repo.delete(equipment_maintenance_vendor, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment_maintenance_vendor changes.

  ## Examples

      iex> change_equipment_maintenance_vendor(equipment_maintenance_vendor)
      %Ecto.Changeset{data: %EquipmentMaintenanceVendor{}}

  """
  def change_equipment_maintenance_vendor(%EquipmentMaintenanceVendor{} = equipment_maintenance_vendor, attrs \\ %{}) do
    EquipmentMaintenanceVendor.changeset(equipment_maintenance_vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentInsuranceVendor

  @doc """
  Returns the list of equipment_insurance_vendors.

  ## Examples

      iex> list_equipment_insurance_vendors()
      [%EquipmentInsuranceVendor{}, ...]

  """
  def list_equipment_insurance_vendors(prefix) do
    Repo.all(EquipmentInsuranceVendor, prefix: prefix)
  end

  def list_equipment_insurance_vendors_by_equipment_id(equipment_id, prefix) do
    from(eiv in EquipmentInsuranceVendor, where: eiv.equipment_id == ^equipment_id)
    |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single equipment_insurance_vendor.

  Raises `Ecto.NoResultsError` if the Equipment insurance vendor does not exist.

  ## Examples

      iex> get_equipment_insurance_vendor!(123)
      %EquipmentInsuranceVendor{}

      iex> get_equipment_insurance_vendor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment_insurance_vendor!(id, prefix), do: Repo.get!(EquipmentInsuranceVendor, id, prefix: prefix)

  @doc """
  Creates a equipment_insurance_vendor.

  ## Examples

      iex> create_equipment_insurance_vendor(%{field: value})
      {:ok, %EquipmentInsuranceVendor{}}

      iex> create_equipment_insurance_vendor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment_insurance_vendor(attrs \\ %{}, prefix) do
    %EquipmentInsuranceVendor{}
    |> EquipmentInsuranceVendor.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a equipment_insurance_vendor.

  ## Examples

      iex> update_equipment_insurance_vendor(equipment_insurance_vendor, %{field: new_value})
      {:ok, %EquipmentInsuranceVendor{}}

      iex> update_equipment_insurance_vendor(equipment_insurance_vendor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment_insurance_vendor(%EquipmentInsuranceVendor{} = equipment_insurance_vendor, attrs, prefix) do
    equipment_insurance_vendor
    |> EquipmentInsuranceVendor.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a equipment_insurance_vendor.

  ## Examples

      iex> delete_equipment_insurance_vendor(equipment_insurance_vendor)
      {:ok, %EquipmentInsuranceVendor{}}

      iex> delete_equipment_insurance_vendor(equipment_insurance_vendor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment_insurance_vendor(%EquipmentInsuranceVendor{} = equipment_insurance_vendor, prefix) do
    Repo.delete(equipment_insurance_vendor, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment_insurance_vendor changes.

  ## Examples

      iex> change_equipment_insurance_vendor(equipment_insurance_vendor)
      %Ecto.Changeset{data: %EquipmentInsuranceVendor{}}

  """
  def change_equipment_insurance_vendor(%EquipmentInsuranceVendor{} = equipment_insurance_vendor, attrs \\ %{}) do
    EquipmentInsuranceVendor.changeset(equipment_insurance_vendor, attrs)
  end

  alias Inconn2Service.AssetInfo.EquipmentAttachment

  @doc """
  Returns the list of equipment_attachments.

  ## Examples

      iex> list_equipment_attachments()
      [%EquipmentAttachment{}, ...]

  """
  def list_equipment_attachments do
    Repo.all(EquipmentAttachment)
  end

  @doc """
  Gets a single equipment_attachment.

  Raises `Ecto.NoResultsError` if the Equipment attachment does not exist.

  ## Examples

      iex> get_equipment_attachment!(123)
      %EquipmentAttachment{}

      iex> get_equipment_attachment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment_attachment!(id), do: Repo.get!(EquipmentAttachment, id)

  @doc """
  Creates a equipment_attachment.

  ## Examples

      iex> create_equipment_attachment(%{field: value})
      {:ok, %EquipmentAttachment{}}

      iex> create_equipment_attachment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment_attachment(attrs \\ %{}) do
    %EquipmentAttachment{}
    |> EquipmentAttachment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a equipment_attachment.

  ## Examples

      iex> update_equipment_attachment(equipment_attachment, %{field: new_value})
      {:ok, %EquipmentAttachment{}}

      iex> update_equipment_attachment(equipment_attachment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment_attachment(%EquipmentAttachment{} = equipment_attachment, attrs) do
    equipment_attachment
    |> EquipmentAttachment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a equipment_attachment.

  ## Examples

      iex> delete_equipment_attachment(equipment_attachment)
      {:ok, %EquipmentAttachment{}}

      iex> delete_equipment_attachment(equipment_attachment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment_attachment(%EquipmentAttachment{} = equipment_attachment) do
    Repo.delete(equipment_attachment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment_attachment changes.

  ## Examples

      iex> change_equipment_attachment(equipment_attachment)
      %Ecto.Changeset{data: %EquipmentAttachment{}}

  """
  def change_equipment_attachment(%EquipmentAttachment{} = equipment_attachment, attrs \\ %{}) do
    EquipmentAttachment.changeset(equipment_attachment, attrs)
  end
end

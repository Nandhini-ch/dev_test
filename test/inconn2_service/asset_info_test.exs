defmodule Inconn2Service.AssetInfoTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.AssetInfo

  describe "manufacturers" do
    alias Inconn2Service.AssetInfo.Manufacturer

    @valid_attrs %{contact: %{}, description: "some description", name: "some name", register_no: "some register_no"}
    @update_attrs %{contact: %{}, description: "some updated description", name: "some updated name", register_no: "some updated register_no"}
    @invalid_attrs %{contact: nil, description: nil, name: nil, register_no: nil}

    def manufacturer_fixture(attrs \\ %{}) do
      {:ok, manufacturer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_manufacturer()

      manufacturer
    end

    test "list_manufacturers/0 returns all manufacturers" do
      manufacturer = manufacturer_fixture()
      assert AssetInfo.list_manufacturers() == [manufacturer]
    end

    test "get_manufacturer!/1 returns the manufacturer with given id" do
      manufacturer = manufacturer_fixture()
      assert AssetInfo.get_manufacturer!(manufacturer.id) == manufacturer
    end

    test "create_manufacturer/1 with valid data creates a manufacturer" do
      assert {:ok, %Manufacturer{} = manufacturer} = AssetInfo.create_manufacturer(@valid_attrs)
      assert manufacturer.contact == %{}
      assert manufacturer.description == "some description"
      assert manufacturer.name == "some name"
      assert manufacturer.register_no == "some register_no"
    end

    test "create_manufacturer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_manufacturer(@invalid_attrs)
    end

    test "update_manufacturer/2 with valid data updates the manufacturer" do
      manufacturer = manufacturer_fixture()
      assert {:ok, %Manufacturer{} = manufacturer} = AssetInfo.update_manufacturer(manufacturer, @update_attrs)
      assert manufacturer.contact == %{}
      assert manufacturer.description == "some updated description"
      assert manufacturer.name == "some updated name"
      assert manufacturer.register_no == "some updated register_no"
    end

    test "update_manufacturer/2 with invalid data returns error changeset" do
      manufacturer = manufacturer_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_manufacturer(manufacturer, @invalid_attrs)
      assert manufacturer == AssetInfo.get_manufacturer!(manufacturer.id)
    end

    test "delete_manufacturer/1 deletes the manufacturer" do
      manufacturer = manufacturer_fixture()
      assert {:ok, %Manufacturer{}} = AssetInfo.delete_manufacturer(manufacturer)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_manufacturer!(manufacturer.id) end
    end

    test "change_manufacturer/1 returns a manufacturer changeset" do
      manufacturer = manufacturer_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_manufacturer(manufacturer)
    end
  end

  describe "vendors" do
    alias Inconn2Service.AssetInfo.Vendor

    @valid_attrs %{contact: %{}, description: "some description", name: "some name", register_no: "some register_no"}
    @update_attrs %{contact: %{}, description: "some updated description", name: "some updated name", register_no: "some updated register_no"}
    @invalid_attrs %{contact: nil, description: nil, name: nil, register_no: nil}

    def vendor_fixture(attrs \\ %{}) do
      {:ok, vendor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_vendor()

      vendor
    end

    test "list_vendors/0 returns all vendors" do
      vendor = vendor_fixture()
      assert AssetInfo.list_vendors() == [vendor]
    end

    test "get_vendor!/1 returns the vendor with given id" do
      vendor = vendor_fixture()
      assert AssetInfo.get_vendor!(vendor.id) == vendor
    end

    test "create_vendor/1 with valid data creates a vendor" do
      assert {:ok, %Vendor{} = vendor} = AssetInfo.create_vendor(@valid_attrs)
      assert vendor.contact == %{}
      assert vendor.description == "some description"
      assert vendor.name == "some name"
      assert vendor.register_no == "some register_no"
    end

    test "create_vendor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_vendor(@invalid_attrs)
    end

    test "update_vendor/2 with valid data updates the vendor" do
      vendor = vendor_fixture()
      assert {:ok, %Vendor{} = vendor} = AssetInfo.update_vendor(vendor, @update_attrs)
      assert vendor.contact == %{}
      assert vendor.description == "some updated description"
      assert vendor.name == "some updated name"
      assert vendor.register_no == "some updated register_no"
    end

    test "update_vendor/2 with invalid data returns error changeset" do
      vendor = vendor_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_vendor(vendor, @invalid_attrs)
      assert vendor == AssetInfo.get_vendor!(vendor.id)
    end

    test "delete_vendor/1 deletes the vendor" do
      vendor = vendor_fixture()
      assert {:ok, %Vendor{}} = AssetInfo.delete_vendor(vendor)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_vendor!(vendor.id) end
    end

    test "change_vendor/1 returns a vendor changeset" do
      vendor = vendor_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_vendor(vendor)
    end
  end

  describe "service_branches" do
    alias Inconn2Service.AssetInfo.ServiceBranch

    @valid_attrs %{address: %{}, contact: %{}, region: "some region"}
    @update_attrs %{address: %{}, contact: %{}, region: "some updated region"}
    @invalid_attrs %{address: nil, contact: nil, region: nil}

    def service_branch_fixture(attrs \\ %{}) do
      {:ok, service_branch} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_service_branch()

      service_branch
    end

    test "list_service_branches/0 returns all service_branches" do
      service_branch = service_branch_fixture()
      assert AssetInfo.list_service_branches() == [service_branch]
    end

    test "get_service_branch!/1 returns the service_branch with given id" do
      service_branch = service_branch_fixture()
      assert AssetInfo.get_service_branch!(service_branch.id) == service_branch
    end

    test "create_service_branch/1 with valid data creates a service_branch" do
      assert {:ok, %ServiceBranch{} = service_branch} = AssetInfo.create_service_branch(@valid_attrs)
      assert service_branch.address == %{}
      assert service_branch.contact == %{}
      assert service_branch.region == "some region"
    end

    test "create_service_branch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_service_branch(@invalid_attrs)
    end

    test "update_service_branch/2 with valid data updates the service_branch" do
      service_branch = service_branch_fixture()
      assert {:ok, %ServiceBranch{} = service_branch} = AssetInfo.update_service_branch(service_branch, @update_attrs)
      assert service_branch.address == %{}
      assert service_branch.contact == %{}
      assert service_branch.region == "some updated region"
    end

    test "update_service_branch/2 with invalid data returns error changeset" do
      service_branch = service_branch_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_service_branch(service_branch, @invalid_attrs)
      assert service_branch == AssetInfo.get_service_branch!(service_branch.id)
    end

    test "delete_service_branch/1 deletes the service_branch" do
      service_branch = service_branch_fixture()
      assert {:ok, %ServiceBranch{}} = AssetInfo.delete_service_branch(service_branch)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_service_branch!(service_branch.id) end
    end

    test "change_service_branch/1 returns a service_branch changeset" do
      service_branch = service_branch_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_service_branch(service_branch)
    end
  end

  describe "equipment_manufacturers" do
    alias Inconn2Service.AssetInfo.EquipmentManufacturer

    @valid_attrs %{acquired_date: ~D[2010-04-17], capacity: 120.5, commissioned_date: ~D[2010-04-17], country_of_origin: "some country_of_origin", depreciation_factor: 120.5, description: "some description", is_warranty_available: true, model_no: "some model_no", name: "some name", purchase_price: 120.5, serial_no: "some serial_no", unit_of_capacity: "some unit_of_capacity", warranty_from: ~D[2010-04-17], warranty_to: ~D[2010-04-17], year_of_manufacturing: 42}
    @update_attrs %{acquired_date: ~D[2011-05-18], capacity: 456.7, commissioned_date: ~D[2011-05-18], country_of_origin: "some updated country_of_origin", depreciation_factor: 456.7, description: "some updated description", is_warranty_available: false, model_no: "some updated model_no", name: "some updated name", purchase_price: 456.7, serial_no: "some updated serial_no", unit_of_capacity: "some updated unit_of_capacity", warranty_from: ~D[2011-05-18], warranty_to: ~D[2011-05-18], year_of_manufacturing: 43}
    @invalid_attrs %{acquired_date: nil, capacity: nil, commissioned_date: nil, country_of_origin: nil, depreciation_factor: nil, description: nil, is_warranty_available: nil, model_no: nil, name: nil, purchase_price: nil, serial_no: nil, unit_of_capacity: nil, warranty_from: nil, warranty_to: nil, year_of_manufacturing: nil}

    def equipment_manufacturer_fixture(attrs \\ %{}) do
      {:ok, equipment_manufacturer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_equipment_manufacturer()

      equipment_manufacturer
    end

    test "list_equipment_manufacturers/0 returns all equipment_manufacturers" do
      equipment_manufacturer = equipment_manufacturer_fixture()
      assert AssetInfo.list_equipment_manufacturers() == [equipment_manufacturer]
    end

    test "get_equipment_manufacturer!/1 returns the equipment_manufacturer with given id" do
      equipment_manufacturer = equipment_manufacturer_fixture()
      assert AssetInfo.get_equipment_manufacturer!(equipment_manufacturer.id) == equipment_manufacturer
    end

    test "create_equipment_manufacturer/1 with valid data creates a equipment_manufacturer" do
      assert {:ok, %EquipmentManufacturer{} = equipment_manufacturer} = AssetInfo.create_equipment_manufacturer(@valid_attrs)
      assert equipment_manufacturer.acquired_date == ~D[2010-04-17]
      assert equipment_manufacturer.capacity == 120.5
      assert equipment_manufacturer.commissioned_date == ~D[2010-04-17]
      assert equipment_manufacturer.country_of_origin == "some country_of_origin"
      assert equipment_manufacturer.depreciation_factor == 120.5
      assert equipment_manufacturer.description == "some description"
      assert equipment_manufacturer.is_warranty_available == true
      assert equipment_manufacturer.model_no == "some model_no"
      assert equipment_manufacturer.name == "some name"
      assert equipment_manufacturer.purchase_price == 120.5
      assert equipment_manufacturer.serial_no == "some serial_no"
      assert equipment_manufacturer.unit_of_capacity == "some unit_of_capacity"
      assert equipment_manufacturer.warranty_from == ~D[2010-04-17]
      assert equipment_manufacturer.warranty_to == ~D[2010-04-17]
      assert equipment_manufacturer.year_of_manufacturing == 42
    end

    test "create_equipment_manufacturer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_equipment_manufacturer(@invalid_attrs)
    end

    test "update_equipment_manufacturer/2 with valid data updates the equipment_manufacturer" do
      equipment_manufacturer = equipment_manufacturer_fixture()
      assert {:ok, %EquipmentManufacturer{} = equipment_manufacturer} = AssetInfo.update_equipment_manufacturer(equipment_manufacturer, @update_attrs)
      assert equipment_manufacturer.acquired_date == ~D[2011-05-18]
      assert equipment_manufacturer.capacity == 456.7
      assert equipment_manufacturer.commissioned_date == ~D[2011-05-18]
      assert equipment_manufacturer.country_of_origin == "some updated country_of_origin"
      assert equipment_manufacturer.depreciation_factor == 456.7
      assert equipment_manufacturer.description == "some updated description"
      assert equipment_manufacturer.is_warranty_available == false
      assert equipment_manufacturer.model_no == "some updated model_no"
      assert equipment_manufacturer.name == "some updated name"
      assert equipment_manufacturer.purchase_price == 456.7
      assert equipment_manufacturer.serial_no == "some updated serial_no"
      assert equipment_manufacturer.unit_of_capacity == "some updated unit_of_capacity"
      assert equipment_manufacturer.warranty_from == ~D[2011-05-18]
      assert equipment_manufacturer.warranty_to == ~D[2011-05-18]
      assert equipment_manufacturer.year_of_manufacturing == 43
    end

    test "update_equipment_manufacturer/2 with invalid data returns error changeset" do
      equipment_manufacturer = equipment_manufacturer_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_equipment_manufacturer(equipment_manufacturer, @invalid_attrs)
      assert equipment_manufacturer == AssetInfo.get_equipment_manufacturer!(equipment_manufacturer.id)
    end

    test "delete_equipment_manufacturer/1 deletes the equipment_manufacturer" do
      equipment_manufacturer = equipment_manufacturer_fixture()
      assert {:ok, %EquipmentManufacturer{}} = AssetInfo.delete_equipment_manufacturer(equipment_manufacturer)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_equipment_manufacturer!(equipment_manufacturer.id) end
    end

    test "change_equipment_manufacturer/1 returns a equipment_manufacturer changeset" do
      equipment_manufacturer = equipment_manufacturer_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_equipment_manufacturer(equipment_manufacturer)
    end
  end

  describe "equipment_dlp_vendors" do
    alias Inconn2Service.AssetInfo.EquipmentDlpVendor

    @valid_attrs %{dlp_from: ~D[2010-04-17], dlp_to: ~D[2010-04-17], is_asset_under_dlp: true, service_branch_id: 42, vendor_id: 42, vendor_scope: "some vendor_scope"}
    @update_attrs %{dlp_from: ~D[2011-05-18], dlp_to: ~D[2011-05-18], is_asset_under_dlp: false, service_branch_id: 43, vendor_id: 43, vendor_scope: "some updated vendor_scope"}
    @invalid_attrs %{dlp_from: nil, dlp_to: nil, is_asset_under_dlp: nil, service_branch_id: nil, vendor_id: nil, vendor_scope: nil}

    def equipment_dlp_vendor_fixture(attrs \\ %{}) do
      {:ok, equipment_dlp_vendor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_equipment_dlp_vendor()

      equipment_dlp_vendor
    end

    test "list_equipment_dlp_vendors/0 returns all equipment_dlp_vendors" do
      equipment_dlp_vendor = equipment_dlp_vendor_fixture()
      assert AssetInfo.list_equipment_dlp_vendors() == [equipment_dlp_vendor]
    end

    test "get_equipment_dlp_vendor!/1 returns the equipment_dlp_vendor with given id" do
      equipment_dlp_vendor = equipment_dlp_vendor_fixture()
      assert AssetInfo.get_equipment_dlp_vendor!(equipment_dlp_vendor.id) == equipment_dlp_vendor
    end

    test "create_equipment_dlp_vendor/1 with valid data creates a equipment_dlp_vendor" do
      assert {:ok, %EquipmentDlpVendor{} = equipment_dlp_vendor} = AssetInfo.create_equipment_dlp_vendor(@valid_attrs)
      assert equipment_dlp_vendor.dlp_from == ~D[2010-04-17]
      assert equipment_dlp_vendor.dlp_to == ~D[2010-04-17]
      assert equipment_dlp_vendor.is_asset_under_dlp == true
      assert equipment_dlp_vendor.service_branch_id == 42
      assert equipment_dlp_vendor.vendor_id == 42
      assert equipment_dlp_vendor.vendor_scope == "some vendor_scope"
    end

    test "create_equipment_dlp_vendor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_equipment_dlp_vendor(@invalid_attrs)
    end

    test "update_equipment_dlp_vendor/2 with valid data updates the equipment_dlp_vendor" do
      equipment_dlp_vendor = equipment_dlp_vendor_fixture()
      assert {:ok, %EquipmentDlpVendor{} = equipment_dlp_vendor} = AssetInfo.update_equipment_dlp_vendor(equipment_dlp_vendor, @update_attrs)
      assert equipment_dlp_vendor.dlp_from == ~D[2011-05-18]
      assert equipment_dlp_vendor.dlp_to == ~D[2011-05-18]
      assert equipment_dlp_vendor.is_asset_under_dlp == false
      assert equipment_dlp_vendor.service_branch_id == 43
      assert equipment_dlp_vendor.vendor_id == 43
      assert equipment_dlp_vendor.vendor_scope == "some updated vendor_scope"
    end

    test "update_equipment_dlp_vendor/2 with invalid data returns error changeset" do
      equipment_dlp_vendor = equipment_dlp_vendor_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_equipment_dlp_vendor(equipment_dlp_vendor, @invalid_attrs)
      assert equipment_dlp_vendor == AssetInfo.get_equipment_dlp_vendor!(equipment_dlp_vendor.id)
    end

    test "delete_equipment_dlp_vendor/1 deletes the equipment_dlp_vendor" do
      equipment_dlp_vendor = equipment_dlp_vendor_fixture()
      assert {:ok, %EquipmentDlpVendor{}} = AssetInfo.delete_equipment_dlp_vendor(equipment_dlp_vendor)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_equipment_dlp_vendor!(equipment_dlp_vendor.id) end
    end

    test "change_equipment_dlp_vendor/1 returns a equipment_dlp_vendor changeset" do
      equipment_dlp_vendor = equipment_dlp_vendor_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_equipment_dlp_vendor(equipment_dlp_vendor)
    end
  end

  describe "equipment_maintenance_vendors" do
    alias Inconn2Service.AssetInfo.EquipmentMaintenanceVendor

    @valid_attrs %{amc_frequency: 42, amc_from: ~D[2010-04-17], amc_to: ~D[2010-04-17], is_asset_under_amc: true, response_time_in_minutes: 42, service_branch_id: 42, vendor_id: 42, vendor_scope: "some vendor_scope"}
    @update_attrs %{amc_frequency: 43, amc_from: ~D[2011-05-18], amc_to: ~D[2011-05-18], is_asset_under_amc: false, response_time_in_minutes: 43, service_branch_id: 43, vendor_id: 43, vendor_scope: "some updated vendor_scope"}
    @invalid_attrs %{amc_frequency: nil, amc_from: nil, amc_to: nil, is_asset_under_amc: nil, response_time_in_minutes: nil, service_branch_id: nil, vendor_id: nil, vendor_scope: nil}

    def equipment_maintenance_vendor_fixture(attrs \\ %{}) do
      {:ok, equipment_maintenance_vendor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_equipment_maintenance_vendor()

      equipment_maintenance_vendor
    end

    test "list_equipment_maintenance_vendors/0 returns all equipment_maintenance_vendors" do
      equipment_maintenance_vendor = equipment_maintenance_vendor_fixture()
      assert AssetInfo.list_equipment_maintenance_vendors() == [equipment_maintenance_vendor]
    end

    test "get_equipment_maintenance_vendor!/1 returns the equipment_maintenance_vendor with given id" do
      equipment_maintenance_vendor = equipment_maintenance_vendor_fixture()
      assert AssetInfo.get_equipment_maintenance_vendor!(equipment_maintenance_vendor.id) == equipment_maintenance_vendor
    end

    test "create_equipment_maintenance_vendor/1 with valid data creates a equipment_maintenance_vendor" do
      assert {:ok, %EquipmentMaintenanceVendor{} = equipment_maintenance_vendor} = AssetInfo.create_equipment_maintenance_vendor(@valid_attrs)
      assert equipment_maintenance_vendor.amc_frequency == 42
      assert equipment_maintenance_vendor.amc_from == ~D[2010-04-17]
      assert equipment_maintenance_vendor.amc_to == ~D[2010-04-17]
      assert equipment_maintenance_vendor.is_asset_under_amc == true
      assert equipment_maintenance_vendor.response_time_in_minutes == 42
      assert equipment_maintenance_vendor.service_branch_id == 42
      assert equipment_maintenance_vendor.vendor_id == 42
      assert equipment_maintenance_vendor.vendor_scope == "some vendor_scope"
    end

    test "create_equipment_maintenance_vendor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_equipment_maintenance_vendor(@invalid_attrs)
    end

    test "update_equipment_maintenance_vendor/2 with valid data updates the equipment_maintenance_vendor" do
      equipment_maintenance_vendor = equipment_maintenance_vendor_fixture()
      assert {:ok, %EquipmentMaintenanceVendor{} = equipment_maintenance_vendor} = AssetInfo.update_equipment_maintenance_vendor(equipment_maintenance_vendor, @update_attrs)
      assert equipment_maintenance_vendor.amc_frequency == 43
      assert equipment_maintenance_vendor.amc_from == ~D[2011-05-18]
      assert equipment_maintenance_vendor.amc_to == ~D[2011-05-18]
      assert equipment_maintenance_vendor.is_asset_under_amc == false
      assert equipment_maintenance_vendor.response_time_in_minutes == 43
      assert equipment_maintenance_vendor.service_branch_id == 43
      assert equipment_maintenance_vendor.vendor_id == 43
      assert equipment_maintenance_vendor.vendor_scope == "some updated vendor_scope"
    end

    test "update_equipment_maintenance_vendor/2 with invalid data returns error changeset" do
      equipment_maintenance_vendor = equipment_maintenance_vendor_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_equipment_maintenance_vendor(equipment_maintenance_vendor, @invalid_attrs)
      assert equipment_maintenance_vendor == AssetInfo.get_equipment_maintenance_vendor!(equipment_maintenance_vendor.id)
    end

    test "delete_equipment_maintenance_vendor/1 deletes the equipment_maintenance_vendor" do
      equipment_maintenance_vendor = equipment_maintenance_vendor_fixture()
      assert {:ok, %EquipmentMaintenanceVendor{}} = AssetInfo.delete_equipment_maintenance_vendor(equipment_maintenance_vendor)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_equipment_maintenance_vendor!(equipment_maintenance_vendor.id) end
    end

    test "change_equipment_maintenance_vendor/1 returns a equipment_maintenance_vendor changeset" do
      equipment_maintenance_vendor = equipment_maintenance_vendor_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_equipment_maintenance_vendor(equipment_maintenance_vendor)
    end
  end

  describe "equipment_insurance_vendors" do
    alias Inconn2Service.AssetInfo.EquipmentInsuranceVendor

    @valid_attrs %{end_date: ~D[2010-04-17], insurance_policy_no: "some insurance_policy_no", insurance_scope: "some insurance_scope", service_branch_id: 42, start_date: ~D[2010-04-17], vendor_id: 42}
    @update_attrs %{end_date: ~D[2011-05-18], insurance_policy_no: "some updated insurance_policy_no", insurance_scope: "some updated insurance_scope", service_branch_id: 43, start_date: ~D[2011-05-18], vendor_id: 43}
    @invalid_attrs %{end_date: nil, insurance_policy_no: nil, insurance_scope: nil, service_branch_id: nil, start_date: nil, vendor_id: nil}

    def equipment_insurance_vendor_fixture(attrs \\ %{}) do
      {:ok, equipment_insurance_vendor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_equipment_insurance_vendor()

      equipment_insurance_vendor
    end

    test "list_equipment_insurance_vendors/0 returns all equipment_insurance_vendors" do
      equipment_insurance_vendor = equipment_insurance_vendor_fixture()
      assert AssetInfo.list_equipment_insurance_vendors() == [equipment_insurance_vendor]
    end

    test "get_equipment_insurance_vendor!/1 returns the equipment_insurance_vendor with given id" do
      equipment_insurance_vendor = equipment_insurance_vendor_fixture()
      assert AssetInfo.get_equipment_insurance_vendor!(equipment_insurance_vendor.id) == equipment_insurance_vendor
    end

    test "create_equipment_insurance_vendor/1 with valid data creates a equipment_insurance_vendor" do
      assert {:ok, %EquipmentInsuranceVendor{} = equipment_insurance_vendor} = AssetInfo.create_equipment_insurance_vendor(@valid_attrs)
      assert equipment_insurance_vendor.end_date == ~D[2010-04-17]
      assert equipment_insurance_vendor.insurance_policy_no == "some insurance_policy_no"
      assert equipment_insurance_vendor.insurance_scope == "some insurance_scope"
      assert equipment_insurance_vendor.service_branch_id == 42
      assert equipment_insurance_vendor.start_date == ~D[2010-04-17]
      assert equipment_insurance_vendor.vendor_id == 42
    end

    test "create_equipment_insurance_vendor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_equipment_insurance_vendor(@invalid_attrs)
    end

    test "update_equipment_insurance_vendor/2 with valid data updates the equipment_insurance_vendor" do
      equipment_insurance_vendor = equipment_insurance_vendor_fixture()
      assert {:ok, %EquipmentInsuranceVendor{} = equipment_insurance_vendor} = AssetInfo.update_equipment_insurance_vendor(equipment_insurance_vendor, @update_attrs)
      assert equipment_insurance_vendor.end_date == ~D[2011-05-18]
      assert equipment_insurance_vendor.insurance_policy_no == "some updated insurance_policy_no"
      assert equipment_insurance_vendor.insurance_scope == "some updated insurance_scope"
      assert equipment_insurance_vendor.service_branch_id == 43
      assert equipment_insurance_vendor.start_date == ~D[2011-05-18]
      assert equipment_insurance_vendor.vendor_id == 43
    end

    test "update_equipment_insurance_vendor/2 with invalid data returns error changeset" do
      equipment_insurance_vendor = equipment_insurance_vendor_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_equipment_insurance_vendor(equipment_insurance_vendor, @invalid_attrs)
      assert equipment_insurance_vendor == AssetInfo.get_equipment_insurance_vendor!(equipment_insurance_vendor.id)
    end

    test "delete_equipment_insurance_vendor/1 deletes the equipment_insurance_vendor" do
      equipment_insurance_vendor = equipment_insurance_vendor_fixture()
      assert {:ok, %EquipmentInsuranceVendor{}} = AssetInfo.delete_equipment_insurance_vendor(equipment_insurance_vendor)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_equipment_insurance_vendor!(equipment_insurance_vendor.id) end
    end

    test "change_equipment_insurance_vendor/1 returns a equipment_insurance_vendor changeset" do
      equipment_insurance_vendor = equipment_insurance_vendor_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_equipment_insurance_vendor(equipment_insurance_vendor)
    end
  end

  describe "equipment_attachments" do
    alias Inconn2Service.AssetInfo.EquipmentAttachment

    @valid_attrs %{attachment: "some attachment", attachment_type: "some attachment_type", name: "some name"}
    @update_attrs %{attachment: "some updated attachment", attachment_type: "some updated attachment_type", name: "some updated name"}
    @invalid_attrs %{attachment: nil, attachment_type: nil, name: nil}

    def equipment_attachment_fixture(attrs \\ %{}) do
      {:ok, equipment_attachment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AssetInfo.create_equipment_attachment()

      equipment_attachment
    end

    test "list_equipment_attachments/0 returns all equipment_attachments" do
      equipment_attachment = equipment_attachment_fixture()
      assert AssetInfo.list_equipment_attachments() == [equipment_attachment]
    end

    test "get_equipment_attachment!/1 returns the equipment_attachment with given id" do
      equipment_attachment = equipment_attachment_fixture()
      assert AssetInfo.get_equipment_attachment!(equipment_attachment.id) == equipment_attachment
    end

    test "create_equipment_attachment/1 with valid data creates a equipment_attachment" do
      assert {:ok, %EquipmentAttachment{} = equipment_attachment} = AssetInfo.create_equipment_attachment(@valid_attrs)
      assert equipment_attachment.attachment == "some attachment"
      assert equipment_attachment.attachment_type == "some attachment_type"
      assert equipment_attachment.name == "some name"
    end

    test "create_equipment_attachment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AssetInfo.create_equipment_attachment(@invalid_attrs)
    end

    test "update_equipment_attachment/2 with valid data updates the equipment_attachment" do
      equipment_attachment = equipment_attachment_fixture()
      assert {:ok, %EquipmentAttachment{} = equipment_attachment} = AssetInfo.update_equipment_attachment(equipment_attachment, @update_attrs)
      assert equipment_attachment.attachment == "some updated attachment"
      assert equipment_attachment.attachment_type == "some updated attachment_type"
      assert equipment_attachment.name == "some updated name"
    end

    test "update_equipment_attachment/2 with invalid data returns error changeset" do
      equipment_attachment = equipment_attachment_fixture()
      assert {:error, %Ecto.Changeset{}} = AssetInfo.update_equipment_attachment(equipment_attachment, @invalid_attrs)
      assert equipment_attachment == AssetInfo.get_equipment_attachment!(equipment_attachment.id)
    end

    test "delete_equipment_attachment/1 deletes the equipment_attachment" do
      equipment_attachment = equipment_attachment_fixture()
      assert {:ok, %EquipmentAttachment{}} = AssetInfo.delete_equipment_attachment(equipment_attachment)
      assert_raise Ecto.NoResultsError, fn -> AssetInfo.get_equipment_attachment!(equipment_attachment.id) end
    end

    test "change_equipment_attachment/1 returns a equipment_attachment changeset" do
      equipment_attachment = equipment_attachment_fixture()
      assert %Ecto.Changeset{} = AssetInfo.change_equipment_attachment(equipment_attachment)
    end
  end
end

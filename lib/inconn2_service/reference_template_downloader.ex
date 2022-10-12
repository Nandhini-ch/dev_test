defmodule Inconn2Service.ReferenceTemplateDownloader do

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.Staff
  alias Inconn2Service.Assignments
  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.ContractManagement
  alias Inconn2Service.Workorder
  alias Inconn2Service.Ticket
  alias Inconn2Service.Settings

  def download_template(prefix, query_params) do
    case query_params["table"] do
      "asset_category" -> download_asset_categories(prefix)
      "task_list" -> download_task_lists(prefix)
      "check_list" -> download_check_lists(prefix)
      "user" -> download_users(prefix)
      "zone" -> download_zones(prefix)
      "site" -> download_sites(prefix)
      "location" -> download_locations(prefix)
      "equipment" -> download_equipments(prefix)
      "task" -> download_tasks(prefix)
      "check" -> download_checks(prefix)
      "employee" -> download_employees(prefix)
      "roster" -> download_roster(prefix)
      "inventory_item" -> download_inventory_item(prefix)
      "inventory_supplier" -> donwload_inventory_supplier(prefix)
      "uom_category" -> download_uom_category(prefix)
      "unit_of_measurement" -> download_unit_of_measurement(prefix)
      "conversion" -> download_conversion(prefix)
      "contract" -> download_contract(prefix)
      "scope" -> download_scope(prefix)
      "manpower_configuration" -> download_manpower_configuration(prefix, query_params)
      "workorder_template" -> download_workorder_template(prefix)
      "workorder_schedule" -> download_workorder_schedule(prefix)
      "workrequest_category" -> download_workrequest_category(prefix)
      "workrequest_subcategory" -> download_workrequest_subcategory(prefix)
      "category_helpdesk" -> download_category_helpdesk(prefix)
      "designation" -> download_designation(prefix)
      "shift" -> download_shifts(prefix)
    end
  end

  def download_asset_categories(prefix) do
    asset_categories = AssetConfig.list_asset_categories(prefix)

    header = [["id", "reference", "Name", "Asset Type", "Parent Id", "parent reference"]]

    body =
      Enum.map(asset_categories, fn r ->
        [r.id,"", r.name, r.asset_type, r.parent_id, ""]
      end)

    final_report = header ++ body
    final_report
  end

  def download_task_lists(prefix) do
    task_lists = WorkOrderConfig.list_task_lists(prefix)

    header = [["id", "reference", "Name", "Asset Category Id"]]

    body =
      Enum.map(task_lists, fn r ->
        [r.id, "", r.name, r.asset_category_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_check_lists(prefix) do
    check_lists = CheckListConfig.list_check_lists(prefix, %{})

    header = [["id", "reference", "Name", "Type", "Check Ids"]]

    body =
      Enum.map(check_lists, fn r ->
        [r.id, "", r.name, r.type, convert_array_of_integers_to_string(r.check_ids)]
      end)

      final_report = header ++ body
      final_report
  end

  def download_users(prefix) do
    user = Staff.list_users(prefix)

    header = [["id", "reference", "Username", "Firstname", "Last Name", "Email", "Mobile No", "Role Id", "Party Id", "Employee Id"]]

    body =
      Enum.map(user, fn r ->
        [r.id, "", r.username, r.first_name, r.last_name, r.email, r.mobile_no, convert_array_of_integers_to_string(r.role_id), r.party_id, r.employee_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_zones(prefix) do
    zone = AssetConfig.list_zones(prefix)

    header = [["id", "reference", "Description", "Name", "Parent Id"]]

    body =
    Enum.map(zone, fn r ->
      [r.id, "", r.description, r.name, r.parent_id]
    end)

    final_report = header ++ body
    final_report
  end

  def download_sites(prefix) do
    locations = AssetConfig.list_sites(prefix)

    header = [["id", "reference", "Name", "Description", "Branch", "Area", "Latitude", "Longitude", "Fencing Radius", "Site Code", "Time Zone", "Zone Id", "Party Id", "Address Line 1", "Address Line 2", "City", "State", "Country", "Postcode", "Contact First Name", "Contact Last Name", "Contact Designation", "Contact Email", "Contact Mobile", "Contact Land Line"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.description, r.branch, r.area, r.latitude, r.longitude, r.fencing_radius, r.site_code, r.time_zone, r.zone_id, r.party_id, r.address.address_line1, r.address.address_line2, r.address.city, r.address.state, r.address.country, r.address.postcode, r.contact.first_name, r.contact.last_name, r.contact.designation, r.contact.email, r.contact.mobile, r.contact.land_line]
      end)

    final_report = header ++ body
    final_report
  end

  def download_locations(prefix) do
    locations = AssetConfig.list_active_locations(prefix)

    header = [["id", "reference", "Name", "Description", "Location Code", "Asset Category Id", "Site Id",
     "Parent Id", "parent reference", "Status", "Criticality"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.description, r.location_code,
        r.asset_category_id, r.site_id, r.parent_id, "", r.status, r.criticality, List.last(r.path), ""]
      end)

    final_report = header ++ body
    final_report
  end

  def download_equipments(prefix) do
    locations = AssetConfig.list_equipments(prefix)

    header = [["id", "reference", "Name", "Equipment Code", "Site Id", "Location Id", "Asset Category Id",
    "Connections In", "Connections Out", "Parent Id", "parent reference", "Status", "Criticality", "Tag Name",
    "Description", "Function", "Asset Owned By Id", "Is Movable", "Department","Asset Manager Id", "Maintenance Manager Id", "Asset Class"
    ]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.equipment_code, r.site_id, r.location_id, r.asset_category_id, convert_array_of_integers_to_string(r.connections_in),
        convert_array_of_integers_to_string(r.connections_out), r.parent_id, "", r.status, r.criticality, r.tag_name, r.description, r.function,
        r.asset_owned_by_id, r.is_movable, r.department, r.asset_manager_id,r.maintenance_manager_id, r.asset_class]
      end)

    final_report = header ++ body
    IO.inspect(final_report)
    final_report
  end

  def download_tasks(prefix) do
    tasks = WorkOrderConfig.list_tasks(prefix)

    header = [["id", "reference", "Label", "Task Type", "Estimated Time", "Master Task Type Id"]]

    body =
      Enum.map(tasks, fn r ->
        fixed_attributes = [r.id, "", r.label, r.task_type, r.estimated_time, r.master_task_type_id]
        cond do
          r.task_type in ["IO", "IM"] ->
            variable_attributes = Enum.map(r.config["options"], fn x -> "#{x["label"]}:#{x["value"]}:#{x["raise_ticket"]}" end)
            fixed_attributes ++ variable_attributes
          r.task_type == "MT" ->
            variable_attributes = ["#{r.config["type"]}: #{r.config["UOM"]}"]
            fixed_attributes ++ variable_attributes
          r.task_type == "OB" ->
            variable_attributes = ["#{r.config["min_length"]} - #{r.config["max_length"]}"]
            fixed_attributes ++ variable_attributes
        end
      end)

      final_report = header ++ body
      final_report
  end

  def download_checks(prefix) do
    check = CheckListConfig.list_checks(%{}, prefix)

    header = [["id", "reference", "Label", "Check Type Id"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.label, r.check_type_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_employees(prefix) do
    check = Staff.list_employees(prefix)

    header = [["id", "reference", "First Name", "Last Name", "Employment Start Date", "Employment End Date",
    "Designation", "Designation Id", "Email", "Employee Id", "Landline No", "Mobile No", "Salary", "Create User", "Reports To",
    "Skills", "Org Unit Id", "Party Id", "Role Id"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.first_name, r.last_name, r.employment_start_date, r.employment_end_date,
        r.designation, r.designation_id, r.email, r.employee_id, r.landline_no, r.mobile_no, r.salary, r.has_login_credentials, r.reports_to,
        convert_array_of_integers_to_string(r.skills), r.org_unit_id, r.party_id, r.role_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_roster(prefix) do
    roster = Assignments.list_roster(prefix)

    header = [["id", "reference", "Designation Id", "Site Id", "Employee Id", "Shift Id", "Date"]]

    body =
    Enum.map(roster, fn r ->
      [r.id, "", r.dedignation_id, r.site_id, r.employee_id, r.shift_id, r.date]
    end)

    final_report = header ++ body
    final_report
  end

  def download_inventory_item(prefix) do
    inventory_item = InventoryManagement.list_inventory_items(prefix)

    header = [["id", "reference", "Approval User Id", "Asset Category Ids", "Is Approval Required",
                "Item Type", "Minimum Stock Level", "Name", "Part No", "Remarks", "Unit Price", "Uom Category Id",
                "Consume Unit Of Measurement", "Inventory Unit Of Measurement", "Purchase Unit Of Measurement"]]

    body =
      Enum.map(inventory_item, fn r ->
        [r.id, "", r.approval_user_id, r.asset_category_ids, r.is_approval_required, r.item_type,
         r.minimum_stock_level, r.name, r.part_no, r.remarks, r.unit_price, r.consume_unit_of_measurement_id,
         r.inventory_unit_of_measurement_id, r.purchase_unit_of_measurement_id
        ]
      end)

      final_report = header ++ body
      final_report
  end


  def donwload_inventory_supplier(prefix) do
    inventory_supplier = InventoryManagement.list_inventory_suppliers(prefix)

    header = [["id", "reference", "Business Type", "Contact No", "Contact Person", "Description",
                "Escalation1 Contact Name", "Escalation1 Contact No", "Escalation2 Contact Name", "Escalation2 Contact No",
                "Gst No", "Supplier Code", "Name", "Reference No", "Website"]]

    body =
      Enum.map(inventory_supplier, fn r ->
        [r.id, "", r.business_type, r.contact_no, r.contact_person, r.description, r.escalation1_contact_name,
         r.escalation1_contact_no, r.escalation2_contact_name, r.escalation2_contact_no, r.gst_no, r.supplier_code,
         r.name, r.reference_no, r.website
        ]
      end)


      final_report = header ++ body
      final_report
  end

  def download_uom_category(prefix) do
    uom_category = InventoryManagement.list_uom_categories(prefix)

    header = [["id", "reference", "Description", "name"]]

    body =
      Enum.map(uom_category, fn r ->
        [r.id, "", r.description, r.name]
      end)

      final_report = header ++ body
      final_report
  end

  def download_unit_of_measurement(prefix) do
    unit_of_measurement = InventoryManagement.list_unit_of_measurements(%{}, prefix)

    header = [["id", "reference", "Name", "unit", "Uom Category Id"]]

    body =
      Enum.map(unit_of_measurement, fn r ->
        [r.id, "", r.name, r.unit, r.uom_category_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_conversion(prefix) do
    conversion = InventoryManagement.list_conversions(prefix)

    header = [["id", "reference", "Multiplication Factor", "From Unit Of Measurement Id", "To Unit Of Measurement Id", "Uom Category Id"]]

    body =
      Enum.map(conversion, fn r ->
        [r.id, "", r.multiplication_factor, r.from_unit_of_measurement_id, r.to_unit_of_measurement_id, r.uom_category_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_contract(prefix) do
    contract = ContractManagement.list_contracts(%{}, prefix)

    header = [["id", "reference", "Name",  "Description",  "Start Date", "End Date", "Contract Type", "Is Effective Status", "Party Id"]]

    body =
      Enum.map(contract, fn r ->
        [r.id, "", r.name, r.description,  r.start_date, r.end_date, r.contract_type, r.is_effective_status, r.party_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_scope(prefix) do
    scope = ContractManagement.list_scopes(%{}, prefix)

    header = [["id", "reference", "Name", "Contract Id", "Site Id", "Location Ids", "Asset Category Ids",
               "Is Apllicable To All Asset Category", "Is Applicable To All Location"]]

    body =
      Enum.map(scope, fn r ->
        [r.id, "", r.description, r.is_applicable_to_all_asset_category, r.is_applicable_to_all_location,
        r.asset_category_ids, r.location_ids, r.name, r.site_id, r.contract_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_manpower_configuration(prefix, query_params) do
    manpower_configuration = ContractManagement.list_manpower_configurations(prefix, query_params)

    header = [["id", "reference", "Site Id", "Contract Id", "Designation Id", "Shift Id", "Quantity"]]

    body =
      Enum.map(manpower_configuration, fn r ->
        [r.id, "", r.designation_id, r.quantity, r.shift_id, r.site_id, r.contract_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_workorder_template(prefix) do
    workorder_template = Workorder.list_workorder_templates(prefix)

    header = [["id", "reference", "Name", "Description", "Asset Type", "Task List Id", "Estimated Time", "Scheduled", "Breakdown", "Audit", "Adhoc",
    "Amc", "Repeat Every", "Repeat Unit", "Applicable Start", "Applicable End", "Time Start", "Time End", "Create New", "Max Times", "Tools", "Spares", "Consumables", "Parts",
    "Measuring Instruments", "Workorder Prior Time", "Is Precheck Required", "Precheck List Id", "Is Workpermit Required", "Is Workorder Approval Required",
    "Is Workorder Acknowledgement Required", "Workpermit Check List Id", "Is Loto Required", "Loto Lock Check List Id", "Loto Release Check List Id", "Is Materials Required",
    "Materials", "Is Manpower Required", "Manpower"]]

    body =
      Enum.map(workorder_template, fn r ->
        [r.id, "", r.name, r.description, r.asset_type, r.task_list_id, r.estimated_time, r.scheduled, r.breakdown, r.audit, r.adhoc,
         r.amc, r.repeat_every, r.repeat_unit, r.applicable_start, r.applicable_end, r.time_start, r.time_end, r.create_new, r.max_times, convert_array_of_map_to_string(r.tools), convert_array_of_map_to_string(r.spares), convert_array_of_map_to_string(r.consumables), convert_array_of_map_to_string(r.parts),
         convert_array_of_map_to_string(r.measuring_instruments), r.workorder_prior_time, r.is_precheck_required, r.precheck_list_id, r.is_workpermit_required, r.is_workorder_approval_required,
         r.is_workorder_acknowledgement_required, r.workpermit_check_list_id, r.is_loto_required, r.loto_lock_check_list_id, r.loto_release_check_list_id, r.is_materials_required,
          r.materials, r.is_manpower_required, r.manpower]
      end)

      final_report = header ++ body
      final_report
   end

   def download_workorder_schedule(prefix) do
     workorder_schedule = Workorder.list_workorder_schedules(prefix)

     header = [["id", "reference", "Asset Id", "Asset Type", "First Occurrence Date", "Next Occurrence Date", "First Occurrence Time", "Next Ocuurence Time", "Holidays",
                 "Workorder Approval User Id", "Workorder Acknowledgement User Id", "Workpermit Approval User Ids", "Loto Checker User Id"]]

     body =
        Enum.map(workorder_schedule, fn r ->
          [r.id, "", r.asset_id, r.asset_type, r.first_occurrence_date, r.next_occurrence_date, r.first_occurrence_time, r.next_occurrence_time,
           r.holidays, r.workorder_approval_user_id, r.workorder_acknowledgement_user_id, r.workpermit_approval_user_ids, r.loto_checker_user_id]
        end)

        final_report = header ++ body
        final_report
   end

   def download_workrequest_category(prefix) do
     workrequest_category = Ticket.list_workrequest_categories(prefix)

     header = [["id", "reference", "Name", "Description"]]

     body =
      Enum.map(workrequest_category, fn r ->
       [r.id, "", r.name, r.description]
     end)

     final_report = header ++ body
     final_report
   end

   def download_workrequest_subcategory(prefix) do
     workrequest_subcategory = Ticket.list_workrequest_subcategories_for_category(1, prefix)

     header = [["id", "reference", "Name", "Description", "Resolution Tat", "Response Tat", "Workrequest Category Id"]]

     body =
      Enum.map(workrequest_subcategory, fn r ->
        [r.id, "", r.name, r.description, r.resolution_tat, r.response_tat, r.workrequest_category_id]
      end)

      final_report = header ++ body
      final_report
   end

   def download_category_helpdesk(prefix) do
     category_helpdesk = Ticket.list_category_helpdesks(%{}, prefix)

     header = [["id", "reference", "User Id", "Site Id", "Workrequest Category Id"]]

     body =
      Enum.map(category_helpdesk, fn r ->
        [r.id, "", r.user_id, r.site_id, r.workrequest_category_id]
      end)


      final_report = header ++ body
      final_report
   end

   def download_shifts(prefix) do
    shifts = Settings.list_shifts(prefix)

    header = [["id", "reference", "Name", "Start Time", "End Time", "Applicable Days",
              "Start Date", "End Date", "Site Id", "Code"]]

    body =
      Enum.map(shifts, fn r ->
        [r.id, "", r.name, r.start_time, r.end_time, convert_array_of_integers_to_string(r.applicable_days),
        r.start_date, r.end_date, r.site_id, r.code]
      end)

      final_report = header ++ body
      final_report
  end

  def download_designation(prefix) do
    designation = Staff.list_designations(prefix)

    header = [["id", "reference", "Name", "Description"]]

    body =
      Enum.map(designation, fn r ->
        [r.id, "", r.name, r.description]
      end)

      final_report = header ++ body
      final_report
  end

  defp convert_array_of_map_to_string(array_of_maps) do
    if array_of_maps != nil do
      array_of_maps
      |> Enum.map(fn x -> "#{x["item_id"]}:#{x["quantity"]}" end)
      |> Enum.join(",")
    else
      ""
    end
  end

  defp convert_array_of_integers_to_string(array_of_ids) do
    if array_of_ids != nil do
        array_of_ids
        |> Enum.map(fn id -> to_string(id) end)
        |> Enum.join(",")
    else
      ""
    end
  end
end

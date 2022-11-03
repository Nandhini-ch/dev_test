defmodule Inconn2Service.ReferenceDataDownloader do

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Workorder
  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.Staff
  alias Inconn2Service.Assignment
  alias Inconn2Service.Settings
  alias Inconn2Service.Inventory
  alias Inconn2Service.WorkOrderConfig.Task

  def download_locations(prefix) do
    locations = AssetConfig.list_active_locations(prefix)

    header = [["id", "reference", "Name", "Description", "Location Code", "Asset Category Id", "Site Id", "Parent Id", "parent reference"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.description, r.location_code, r.asset_category_id, r.site_id, List.last(r.path), ""]
      end)

    final_report = header ++ body
    final_report
  end

  def download_equipments(prefix) do
    locations = AssetConfig.list_equipments(prefix)

    header = [["id", "reference", "Name", "Equipment Code", "Site Id", "Location Id", "Asset Category Id", "Connections In", "Connections Out", "Parent Id", "parent reference"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.equipment_code, r.site_id, r.location_id, r.asset_category_id, convert_array_of_integers_to_string(r.connections_in), convert_array_of_integers_to_string(r.connections_out), List.last(r.path), ""]
      end)

    final_report = header ++ body
    IO.inspect(final_report)
    final_report
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

  def download_sites(prefix) do
    locations = AssetConfig.list_sites(prefix)

    header = [["id", "reference", "Name", "Description", "Branch", "Area", "Latitude", "Longitude", "Fencing Radius", "Site Code", "Time Zone", "Party Id", "Address Line 1", "Address Line 2", "City", "State", "Country", "Postcode", "Contact First Name", "Contact Last Name", "Contact Designation", "Contact Email", "Contact Mobile", "Contact Land Line"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.description, r.branch, r.area, r.latitude, r.longitude, r.fencing_radius, r.site_code, r.time_zone, r.party_id, r.address.address_line1, r.address.address_line2, r.address.city, r.address.state, r.address.country, r.address.postcode, r.contact.first_name, r.contact.last_name, r.contact.designation, r.contact.email, r.contact.land_line]
      end)

    final_report = header ++ body
    final_report
  end

  def download_work_order_templates(prefix) do
    workorder_templates = Workorder.list_workorder_templates(prefix)

    header = [["id", "reference", "Asset Category Id", "Asset Type", "Name", "Task List Id", "Tasks", "Estimated Time", "Scheduled",
     "Repeat Every", "Repeat Unit", "Applicable Start", "Applicable End", "Time Start", "Time End", "Create New", "Max Times",
     "Work Order Prior Time", "Work Permit Required", "Work Permit Check List Id", "Loto Required", "Loto Lock Check List Id",
     "Loto Release Check List Id",]]

    body =
      Enum.map(workorder_templates, fn r ->
        [r.id, "", r.asset_category_id, r.asset_type, r.name, r.task_list_id, get_only_ids_for_workorder_tasks(r.tasks), r.estimated_time, r.scheduled,
        r.repeat_every, r.repeat_unit, r.applicable_start, r.applicable_end, r.time_start, r.time_end, r.create_new, r.max_times,
        r.workorder_prior_time, r.workpermit_required, r.workpermit_check_list_id, r.loto_required, r.loto_lock_check_list_id,
        r.loto_release_check_list_id]
      end)

    final_report = header ++ body
    final_report
  end

  def download_task_lists(prefix) do
    task_lists = WorkOrderConfig.list_task_lists(prefix)

    header = [["id", "reference", "Name", "Task Ids", "Asset Category Id"]]

    body =
      Enum.map(task_lists, fn r ->
        [r.id, "", r.name, convert_array_of_integers_to_string(r.task_ids, prefix), r.asset_category_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_check_lists(prefix) do
    check_lists = CheckListConfig.list_check_lists(prefix)

    header = [["id", "reference", "Name", "Type", "Check Ids"]]

    body =
      Enum.map(check_lists, fn r ->
        [r.id, "", r.name, r.type, convert_array_of_integers_to_string(r.check_ids)]
      end)

      final_report = header ++ body
      final_report
  end

  def download_checks(prefix) do
    check = CheckListConfig.list_checks(%{}, prefix)

    header = [["id", "reference", "Label", "Type"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.label, r.type]
      end)

      final_report = header ++ body
      final_report
  end

  def download_employees(prefix) do
    check = Staff.list_employees(prefix)

    header = [["id", "reference", "First Name", "Last Name", "Employment Start Date", "Employment End Date",
    "Designation", "Email", "Employee Id", "Landline No", "Mobile No", "Salary", "Create User?", "Reports To",
    "Skills", "Org Unit Id", "Party Id"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.first_name, r.last_name, r.employement_start_date, r.employment_end_date,
        r.designation, r.email, r.employee_id, r.landline_no, r.mobile_no, r.salary, r.has_login_credentials, r.reports_to,
        convert_array_of_integers_to_string(r.skills), r.org_unit_id, r.party_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_users(prefix) do
    check = Staff.list_users(prefix)

    header = [["id", "reference", "Email", "Mobile No", "Username", "Role Id", "Party Id"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.email, r.mobile_no, r.username, convert_array_of_integers_to_string(r.role_id), r.party_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_employee_rosters(prefix) do
    check = Assignment.list_employee_rosters(prefix)

    header = [["id", "reference", "Employee Id", "Site Id", "Shift Id", "Start Date", "End Date"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.employee_id, r.site_id, r.shift_id, r.start_date, r.end_date]
      end)

      final_report = header ++ body
      final_report
  end

  def download_org_units(prefix) do
    org_units = Staff.list_org_units(prefix)

    header = [["id", "reference", "Name", "Party Id", "Parent Id", "parent reference"]]

    body =
      Enum.map(org_units, fn r ->
        [r.id, "", r.name, r.party_id, r.parent_id, ""]
      end)

      final_report = header ++ body
      final_report
  end

  def download_bankholidays(prefix) do
    org_units = Settings.list_bankholidays(prefix)

    header = [["id", "reference", "Name", "Start Date", "End Date", "Site Id"]]

    body =
      Enum.map(org_units, fn r ->
        [r.id, "", r.name, r.start_date, r.end_date, r.site_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_shifts(prefix) do
    shifts = Settings.list_shifts(prefix)

    header = [["id", "reference", "Name", "Start Time", "End Time", "Applicable Days",
    "Start Date", "End Date", "Site Id"]]

    body =
      Enum.map(shifts, fn r ->
        [r.id, "", r.name, r.start_time, r.end_time, convert_array_of_integers_to_string(r.applicable_days),
        r.start_date, r.end_date, r.site_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_tasks(prefix) do
    tasks = WorkOrderConfig.list_tasks(prefix)

    header = [["id", "reference", "Label", "Task Type", "Master task type id", "Estimated Time"]]

    body =
      Enum.map(tasks, fn r ->
        fixed_attributes = [r.id, "", r.label, r.task_type, r.master_task_type_id, r.estimated_time]
        cond do
          r.task_type in ["IO", "IM"] ->
            variable_attributes = Enum.map(r.config["options"], fn x -> "#{x["label"]}:#{x["value"]}" end)
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

  def download_workorder_schedules(prefix) do
    workorder_schedules = Workorder.list_workorder_schedules(prefix)

    header = [["id", "reference", "Workorder Template Id", "Asset Id", "Asset Type", "Holidays", "First Occurrence Date", "First Occurrence Time",
             "Next Occurrence Date", "Next Occurrence Time"]]

    body =
      Enum.map(workorder_schedules, fn r ->
        # IO.inspect(r)
        [r.id, "", r.workorder_template_id, r.asset_id, r.asset_type, convert_array_of_integers_to_string(r.holidays), r.first_occurrence_date, r.first_occurrence_time,
        r.next_occurrence_date, r.next_occurrence_time]
      end)

    final_report = header ++ body
    final_report
  end

  def download_inventory_locations(prefix) do
    inventory_locations = Inventory.list_inventory_locations(prefix)
    header = [["id", "reference", "Description", "Name", "Site Id", "Site Location Id"]]

    body = Enum.map(inventory_locations, fn l ->
      [l.id, "", l.description, l.name, l.site_id, l.site_location_id]
    end)

    header ++ body
  end

  def download_inventory_stocks(prefix) do
    inventory_stocks = Inventory.list_inventory_stocks(prefix)
    header = [["id", "reference", "Inventory Location Id", "Item Id", "Quantity"]]

    body = Enum.map(inventory_stocks, fn s ->
      [s.id, "", s.inventory_location_id, s.item_id, s.quantity]
    end)

    header ++ body
  end

  def download_items(prefix) do
    items = Inventory.list_items(prefix)
    header = [["id", "reference", "Name", "Part No", "Asset Category Ids", "Consume Unit Uom Id", "Inventory Unit Uom Id",
               "Purchase Unit Uom Id", "Min Order Quantity", "Reorder Quantity", "Type", "Aisle", "Row", "Bin"]]

    body = Enum.map(items, fn i ->
      [i.id, "", i.name, i.part_no, convert_array_of_integers_to_string(i.asset_categories_ids), i.consume_unit_uom_id,
        i.inventory_unit_uom_id, i.purchase_unit_uom_id, i.min_order_quantity, i.reorder_quantity, i.type, i.aisle,
        i.row, i.bin]
    end)

    header ++ body
  end

  def download_suppliers(prefix) do
    suppliers = Inventory.list_suppliers(prefix)
    header = [["id", "reference", "Name", "Description", "Nature of Business", "Registration No",
               "GST No", "Website", "Remarks", "Contact First Name", "Contact Last Name",
               "Contact Designation", "Contact Email", "Contact Mobile", "Contact Land Line"]]

    body = Enum.map(suppliers, fn s ->
      [s.id, "", s.name, s.description, s.nature_of_business, s.registration_no, s.gst_no,
        s.website, s.remarks, s.contact.first_name, s.contact.last_name, s.contact.designation,
        s.contact.email, s.contact.mobile, s.contact.land_line]
    end)

    header ++ body
  end

  @spec download_supplier_items(any) :: [...]
  def download_supplier_items(prefix) do
    supplier_items = Inventory.list_supplier_items(prefix)
    header = [["id", "reference", "Supplier Id", "Item Id", "Price", "Price Unit Uom Id",
               "Supplier Part No"]]

    body = Enum.map(supplier_items, fn s ->
      [s.id, "", s.supplier_id, s.item_id, s.price, s.price_unit_uom_id, s.supplier_part_no]
    end)

    header ++ body
  end

  def download_uoms(prefix) do
    uoms = Inventory.list_uoms(prefix)
    header = [["id", "reference", "Name", "Symbol"]]

    body = Enum.map(uoms, fn s ->
      [s.id, "", s.name, s.symbol]
    end)

    header ++ body
  end

  def download_uom_conversions(prefix) do
    uom_conversions = Inventory.list_uom_conversions(prefix)
    header = [["id", "reference", "", "from_uom_id", "to_uom_id", "mult_factor", "inverse_factor"]]

    body = Enum.map(uom_conversions, fn s ->
      [s.id, "", s.from_uom_id, s.to_uom_id, s.mult_factor, s.inverse_factor]
    end)

    header ++ body
  end

  def download_roles(prefix) do
    roles = Staff.list_roles(prefix)
    header = [["id", "reference", "Name", "Description"]]

    body = Enum.map(roles, fn r ->
      [[r.id, "", r.name, r.description]]
    end)

    header ++ body
  end

  def download_asset_qrs(prefix) do
    locations_qr = Inconn2Service.AssetConfig.list_locations_qr(1, prefix)

    data =
      Enum.map(locations_qr, fn x ->
        "inc_" <> sub_domain = prefix
        IO.inspect("http://#{sub_domain}.inconn.com:4000#{x.asset_qr_url}")
        ~s(<div class="col-4"><img src="#{sub_domain}.localhost:4000#{x.asset_qr_url}" height="200px" width="200px"/><h3>#{x.asset_name}</h3></div>)
      end) |> Enum.join()

      header = [["divs"]]
      body = [[data]]

      header ++ body
  end

  # defp convert_array_of_objects_to_string(array_of_objects) do
  #   array_of_objects
  #   |> Enum.map(fn x -> IO.inspect(x) end)
  #   |> Enum.join(",")
  # end


  defp convert_array_of_integers_to_string(array_of_ids) do
    if array_of_ids != nil do
        array_of_ids
        |> Enum.map(fn id -> to_string(id) end)
        |> Enum.join(",")
    else
      ""
    end
  end


  defp convert_array_of_integers_to_string(array_of_ids, prefix) do
    if array_of_ids != nil do
        array_of_ids
        |> Stream.map(fn id -> !is_nil(Repo.get(Task, id, prefix: prefix)) end)
        |> Stream.map(fn id -> to_string(id) end)
        |> Enum.join(",")
    else
      ""
    end
  end

  defp get_only_ids_for_workorder_tasks(nil), do: ""

  defp get_only_ids_for_workorder_tasks(array_of_maps) do
    array_of_maps
    |> Enum.map(fn(map) -> map["id"] end)
    |> Enum.join(",")
  end

  # def convert_array_of_integers_to_string([]), do: []

end

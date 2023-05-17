defmodule Inconn2Service.FileLoader do

  def make_zones(record) do
  %{}
  |> Map.put("name", Map.get(record, "Name"))
  |> Map.put("description", Map.get(record, "Description"))
  |> Map.put("parent_id", Map.get(record, "Parent Id"))
  end

  def make_sites(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("description", Map.get(record, "Description"))
    |> Map.put("branch",  Map.get(record, "Branch"))
    |> Map.put("area", Map.get(record, "Area"))
    |> Map.put("latitude", Map.get(record, "Latitude"))
    |> Map.put("longitude", Map.get(record, "Longitude"))
    |> Map.put("fencing_radius", Map.get(record, "Fencing Radius"))
    |> Map.put("site_code", Map.get(record, "Site Code"))
    |> Map.put("time_zone", Map.get(record, "Time Zone"))
    |> Map.put("party_id", Map.get(record, "Party Id"))
    |> Map.put("address", Map.get(record, "Address"))
    |> Map.put("contact", Map.get(record, "Contact"))
    |> Map.put("zone_id", Map.get(record, "Zone Id"))
  end

  def make_asset_categories(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("asset_type", Map.get(record, "Asset Type"))
    |> Map.put("parent_id", Map.get(record, "Parent Id"))
  end

  def make_locations(record) do
      %{}
      |> Map.put("name", Map.get(record, "Name"))
      |> Map.put("description", Map.get(record, "Description"))
      |> Map.put("location_code", Map.get(record, "Location Code"))
      |> Map.put("asset_category_id", Map.get(record, "Asset Category Id"))
      |> Map.put("site_id", Map.get(record, "Site Id"))
      |> Map.put("criticality", Map.get(record, "Criticality"))
      |> Map.put("status", Map.get(record, "Status"))
      |> Map.put("parent_id", Map.get(record, "Parent Id"))
  end

  def make_equipments(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("equipment_code", Map.get(record, "Equipment Code"))
    |> Map.put("location_id", Map.get(record, "Location Id"))
    |> Map.put("asset_category_id", Map.get(record, "Asset Category Id"))
    |> Map.put("connections_in", Map.get(record, "Connections In"))
    |> Map.put("connections_out", Map.get(record, "Connections Out"))
    |> Map.put("site_id", Map.get(record, "Site Id"))
    |> Map.put("parent_id", Map.get(record, "Parent Id"))
    |> Map.put("status", Map.get(record, "Status"))
    |> Map.put("criticality", Map.get(record, "Criticality"))
    |> Map.put("tag_name", Map.get(record, "Tag Name"))
    |> Map.put("description", Map.get(record, "Description"))
    |> Map.put("function", Map.get(record, "Function"))
    |> Map.put("asset_owned_by_id", Map.get(record, "Asset Owned By Id"))
    |> Map.put("is_movable", Map.get(record, "Is Movable"))
    |> Map.put("department", Map.get(record, "Department"))
    |> Map.put("asset_manager_id", Map.get(record, "Asset Manager Id"))
    |> Map.put("maintenance_manager_id", Map.get(record, "Maintenance Manager Id"))
    |> Map.put("asset_class", Map.get(record, "Asset Class"))
  end

  def make_check_types(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("description", Map.get(record, "Description"))
  end

  def make_checks(record) do
    %{}
    |> Map.put("label", Map.get(record, "Label"))
    |> Map.put("check_type_id", Map.get(record, "Check Type Id"))
    # |> Map.put("type", Map.get(record, "Type"))
  end

  def make_check_lists(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("type", Map.get(record, "Type"))
    |> Map.put("check_ids", Map.get(record, "Check Ids"))
  end

  def make_master_task_types(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("description", Map.get(record, "Description"))
  end

  def make_tasks(record) do
    config =
      %{}
      |> Map.put("UOM", Map.get(record, "UOM"))
      |> Map.put("category", Map.get(record, "Category"))
      |> Map.put("max_length", Map.get(record, "Max Length"))
      |> Map.put("min_length", Map.get(record, "Min Length"))
      |> Map.put("max_value", Map.get(record, "Max Value"))
      |> Map.put("min_value", Map.get(record, "Min Value"))
      |> Map.put("threshold_value", Map.get(record, "Threshold Value"))
      |> Map.put("type", Map.get(record, "Type"))
      |> Map.put("options", Map.get(record, "Options"))

      %{}
      |> Map.put("label", Map.get(record, "Label"))
      |> Map.put("task_type", Map.get(record, "Task Type"))
      |> Map.put("estimated_time", Map.get(record, "Estimated Time"))
      |> Map.put("master_task_type_id", Map.get(record, "Master Task Type Id"))
      |> Map.put("config", config)
    end

  def make_task_lists(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("tasks", Map.get(record, "Task Ids"))
    |> Map.put("asset_category_id", Map.get(record, "Asset Category Id"))
  end

  def make_workorder_templates(record) do
    %{}
    |> Map.put("applicable_start", Map.get(record, "Applicable Start"))
    |> Map.put("applicable_end", Map.get(record, "Applicable End"))
    |> Map.put("asset_category_id", Map.get(record, "Asset Category Id"))
    |> Map.put("asset_type", Map.get(record, "Asset Type"))
    |> Map.put("create_new", Map.get(record, "Create New"))
    |> Map.put("estimated_time", Map.get(record, "Estimated Time"))
    |> Map.put("loto_lock_check_list_id", Map.get(record, "Loto Lock Check List Id"))
    |> Map.put("loto_release_check_list_id", Map.get(record, "Loto Release Check List Id"))
    |> Map.put("loto_required", Map.get(record, "Loto Required"))
    |> Map.put("max_times", Map.get(record, "Max Times"))
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("precheck_list_id", Map.get(record, "Precheck List Id"))
    |> Map.put("is_precheck_required", Map.get(record, "Precheck Required"))
    |> Map.put("repeat_every", Map.get(record, "Repeat Every"))
    |> Map.put("repeat_unit", Map.get(record, "Repeat Unit"))
    |> Map.put("scheduled", Map.get(record, "Scheduled"))
    |> Map.put("task_list_id", Map.get(record, "Task List Id"))
    |> Map.put("time_end", Map.get(record, "Time End"))
    |> Map.put("time_start", Map.get(record, "Time Start"))
    |> Map.put("is_workorder_acknowledgement_required", Map.get(record, "Work Order Acknowledgement Required"))
    |> Map.put("is_workorder_approval_required", Map.get(record, "Work Order Approval Required"))
    |> Map.put("workorder_prior_time", Map.get(record, "Work Order Prior Time"))
    |> Map.put("Workpermit_check_list_id", Map.get(record, "Work Permit Check List Id"))
    |> Map.put("workpermit_required", Map.get(record, "Work Permit Required"))
    # |> Map.put("tasks", Map.get(record, "Tasks"))
  end

  def make_workorder_schedules(record) do
    %{}
    |> Map.put("workorder_template_id", Map.get(record, "Workorder Template Id"))
    |> Map.put("asset_id", Map.get(record, "Asset Id"))
    |> Map.put("asset_type", Map.get(record, "Asset Type"))
    |> Map.put("holidays", Map.get(record, "Holidays"))
    |> Map.put("first_occurrence_date", Map.get(record, "First Occurrence Date"))
    |> Map.put("first_occurrence_time", Map.get(record, "First Occurrence Time"))
    |> Map.put("next_occurrence_date", Map.get(record, "Next Occurrence Date"))
    |> Map.put("next_occurrence_time", Map.get(record, "Next Occurrence Time"))
  end

  def make_employees(record) do
    %{}
    |> Map.put("first_name", Map.get(record, "First Name"))
    |> Map.put("last_name", Map.get(record, "Last Name"))
    |> Map.put("employment_start_date", Map.get(record, "Employment Start Date"))
    |> Map.put("employment_end_date", Map.get(record, "Employment End Date"))
    |> Map.put("designation_id", Map.get(record, "Designation Id"))
    |> Map.put("email", Map.get(record, "Email"))
    |> Map.put("employee_id", Map.get(record, "Employee Id"))
    |> Map.put("landline_no", Map.get(record, "Landline No"))
    |> Map.put("mobile_no", Map.get(record, "Mobile No"))
    |> Map.put("salary", Map.get(record, "Salary"))
    |> Map.put("has_login_credentials", Map.get(record, "Create User?"))
    |> Map.put("role_id", Map.get(record, "Role Id"))
    |> Map.put("reports_to", Map.get(record, "Reports To"))
    |> Map.put("skills", Map.get(record, "Skills"))
    |> Map.put("org_unit_id", Map.get(record, "Org Unit Id"))
    |> Map.put("party_id", Map.get(record, "Party Id"))
    |> Map.put("role_id", Map.get(record, "Role Id"))
  end

  def make_inventory_items(record) do
    %{}
    |> Map.put("name", Map.get(record, "Item Name"))
    |> Map.put("part_no", Map.get(record, "Part No"))
    |> Map.put("item_type", Map.get(record, "Item Type"))
    |> Map.put("uom_category_id", Map.get(record, "Uom Type Id"))
    |> Map.put("purchase_unit_of_measurement_id", Map.get(record, "Purchase Unit Uom Id"))
    |> Map.put("inventory_unit_of_measurement_id", Map.get(record, "Inventory Unit Uom Id"))
    |> Map.put("consume_unit_of_measurement_id", Map.get(record, "Consume Unit Uom Id"))
    |> Map.put("unit_price", Map.get(record, "Unit Price"))
    |> Map.put("minimum_stock_level", Map.get(record, "Minimum Stock Level"))
    |> Map.put("remarks", Map.get(record, "Remarks"))
    |> Map.put("asset_category_ids", Map.get(record, "Asset Category Ids"))
    |> Map.put("is_approval_required", Map.get(record, "Is Approval Required"))
    |> Map.put("approval_user_id", Map.get(record, "Approve User"))
  end

  def make_inventory_suppliers(record) do
    %{}
    |> Map.put("name", Map.get(record, "Supplier Name"))
    |> Map.put("reference_no", Map.get(record, "Reference Number"))
    |> Map.put("business_type", Map.get(record, "Business Type"))
    |> Map.put("website", Map.get(record, "Website"))
    |> Map.put("gst_no", Map.get(record, "GST Number"))
    |> Map.put("supplier_code", Map.get(record, "Supplier Code"))
    |> Map.put("description", Map.get(record, "Description"))
    |> Map.put("contact_person", Map.get(record, "Contact Person"))
    |> Map.put("contact_no", Map.get(record, "Contact Number"))
    |> Map.put("escalation1_contact_name", Map.get(record, "Escalation 1 Contact Name"))
    |> Map.put("escalation1_contact_no", Map.get(record, "Escalation 1 Contact Number"))
    |> Map.put("escalation2_contact_name", Map.get(record, "Escalation 2 Contact Name"))
    |> Map.put("escalation2_contact_no", Map.get(record, "Escalation 2 Contact Number"))
  end

  def make_unit_of_measurements(record) do
    %{}
    |> Map.put("name", Map.get(record, "UOM Name"))
    |> Map.put("unit", Map.get(record, "Unit"))
    |> Map.put("uom_category_id", Map.get(record, "UOM Category Type Id"))
  end

  def make_uom_category(record) do
    %{}
    |> Map.put("name", Map.get(record, "UOM Category Name"))
    |> Map.put("description", Map.get(record, "Description"))
  end

  ["id", "reference", "Category Name", "Pan Number", "Address Line 1", "Address Line 2", "Country", "State", "City", "Postcode",
    "First Name", "Last Name", "Designation", "Email", "Mobile", "Landline"
   ]

  def make_party(record) do
   address =
    %{}
    |> Map.put("address_line1", Map.get(record, "Address Line 1"))
    |> Map.put("address_line2", Map.get(record, "Address Line 2"))
    |> Map.put("country", Map.get(record, "Country"))
    |> Map.put("state", Map.get(record, "State"))
    |> Map.put("city", Map.get(record, "City"))
    |> Map.put("postcode", Map.get(record, "Postcode"))

    contact =
    %{}
    |> Map.put("first_name", Map.get(record, "First Name"))
    |> Map.put("last_name", Map.get(record, "Last Name"))
    |> Map.put("designation", Map.get(record, "Designation"))
    |> Map.put("email", Map.get(record, "Email"))
    |> Map.put("mobile", Map.get(record, "Mobile"))
    |> Map.put("land_line", Map.get(record, "Landline"))

    %{}
    |> Map.put("company_name", Map.get(record, "Category Name"))
    |> Map.put("pan_number", Map.get(record, "Pan Number"))
    |> Map.put("party_type", "SP")
    |> Map.put("address", address)
    |> Map.put("contact", contact)
  end

  def make_contract(record) do
    %{}
    |> Map.put("name", Map.get(record, "Contract Name"))
    |> Map.put("start_date", Map.get(record, "Contract Start Date"))
    |> Map.put("end_date", Map.get(record, "Contract End Date"))
    |> Map.put("contract_type", Map.get(record, "Contract Type"))
    |> Map.put("is_effective_status", Map.get(record, "Effective Status"))
    |> Map.put("party_id", Map.get(record, "Service Provider Id"))
  end

  def make_scope(record) do
    %{}
    |> Map.put("asset_category_ids", Map.get(record, "Asset Category Ids"))
    |> Map.put("is_applicable_to_all_asset_category", Map.get(record, "Is Applicable To All Asset Category"))
    |> Map.put("location_ids", Map.get(record, "Location Ids"))
    |> Map.put("is_applicable_to_all_location", Map.get(record, "Is Applicable To All Location"))
    |> Map.put("site_id", Map.get(record, "Site Id"))
    |> Map.put("contract_id", Map.get(record, "Contract Id"))
    |> Map.put("name", "scope")
  end

  def make_users(record) do
    %{}
    |> Map.put("username", Map.get(record, "UserName"))
    |> Map.put("mobile_no", Map.get(record, "Mobile No"))
    |> Map.put("email", Map.get(record, "Email"))
    |> Map.put("role_id", Map.get(record, "Role Id"))
    |> Map.put("party_id", Map.get(record, "Party Id"))
    |> Map.put("first_name", Map.get(record, "First Name"))
    |> Map.put("last_name", Map.get(record, "Last Name"))
    |> Map.put("password", Map.get(record, "Password"))
  end

  def make_org_units(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("party_id", Map.get(record, "Party Id"))
    |> Map.put("active", Map.get(record, "Active"))
    |> Map.put("parent_id", Map.get(record, "Parent Id"))
  end

  def make_shifts(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("start_time", Map.get(record, "Start Time"))
    |> Map.put("end_time", Map.get(record, "End Time"))
    |> Map.put("applicable_days", Map.get(record, "Applicable Days"))
    |> Map.put("start_date", Map.get(record, "Start Date"))
    |> Map.put("end_date", Map.get(record, "End Date"))
    |> Map.put("site_id", Map.get(record, "Site Id"))
  end

  def make_bankholidays(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("start_date", Map.get(record, "Start Date"))
    |> Map.put("end_date", Map.get(record, "End Date"))
    |> Map.put("site_id", Map.get(record, "Site Id"))
  end

  def make_employee_rosters(record) do
    %{}
    |> Map.put("employee_id", Map.get(record, "Employee Id"))
    |> Map.put("site_id", Map.get(record, "Site Id"))
    |> Map.put("shift_id", Map.get(record, "Shift Id"))
    |> Map.put("start_date", Map.get(record, "Start Date"))
    |> Map.put("end_date", Map.get(record, "End Date"))
  end

  def make_uoms(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("symbol", Map.get(record, "Symbol"))
  end

  def make_items(record) do
    %{}
    |> Map.put("asset_categories_ids", Map.get(record, "Asset Category Ids"))
    |> Map.put("consume_unit_uom_id", Map.get(record, "Consume Unit Uom Id"))
    |> Map.put("purchase_unit_uom_id", Map.get(record, "Purchase Unit Uom Id"))
    |> Map.put("inventory_unit_uom_id", Map.get(record, "Inventory Unit Uom Id"))
    |> Map.put("reorder_quantity", Map.get(record, "Reorder Quantity"))
    |> Map.put("min_order_quantity", Map.get(record, "Min Order Quantity"))
    |> Map.put("type", Map.get(record, "Type"))
    |> Map.put("aisle", Map.get(record, "Aisle"))
    |> Map.put("row", Map.get(record, "Row"))
    |> Map.put("bin", Map.get(record, "Bin"))
  end

  def make_supplier_items(record) do
    %{}
    |> Map.put("supplier_id", Map.get(record, "Supplier Id"))
    |> Map.put("item_id", Map.get(record, "Item Id"))
    |> Map.put("price", Map.get(record, "Price"))
    |> Map.put("price_unit_uom_id", Map.get(record, "Price Unit Uom Id"))
    |> Map.put("supplier_part_no", Map.get(record, "Supplier Part No"))
  end

  def convert_special_keys_to_required_type([], map), do: map

  def convert_special_keys_to_required_type(keys, map) do
    [{key_name, type, options} | tail] = keys
    case type do
      "array_of_integers" ->
        array_value =
          if map[key_name] == "", do: [], else: String.split(map[key_name], ",") |> Enum.map(fn x -> String.to_integer(x) end)
        new_map = Map.put(map, key_name, array_value)
        convert_special_keys_to_required_type(tail, new_map)
      "integer_array_tuples_with_index" ->
        array_value =
          if map[key_name] == "", do: [], else: String.split(map[key_name], ",") |> Enum.map(fn x -> String.to_integer(x) end) |> Enum.with_index(1) |> Enum.map(fn {v, i} -> %{"id" => v, "order" => i} end)
        new_map = Map.put(map, key_name, array_value)
        convert_special_keys_to_required_type(tail, new_map)

      "date" ->
        new_map =
          if map[key_name] != "" &&  is_binary(map[key_name]) do
            [date, month, year] = String.split(map[key_name], "-")
            {:ok, date} = Date.from_iso8601("#{year}-#{month}-#{date}")
            Map.put(map, key_name, date)
          else
            map
          end
        convert_special_keys_to_required_type(tail, new_map)

        "time" ->
          new_map =
            if map[key_name] != "" &&  is_binary(map[key_name]) do
              [hh, mm, ss] = String.split(map[key_name], ":")
              {:ok, time} = Time.from_iso8601("#{hh}:#{mm}:#{ss}")
              Map.put(map, key_name, time)
            else
              map
            end
          convert_special_keys_to_required_type(tail, new_map)

      "boolean" ->
        value = if map[key_name] in ["TRUE", "True", "true"], do: true, else: false
        new_map = Map.put(map, key_name, value)
        convert_special_keys_to_required_type(tail, new_map)

      "map_out_of_existing_options" ->
        actual_keys =
          Enum.map(options, fn {_readble_key, actual_key} ->
            actual_key
          end)
        submap_value_list =
          Enum.map(options, fn {readble_key, _actual_key} ->
            map[readble_key]
          end)
          submap = Enum.zip(actual_keys, submap_value_list) |> Enum.into(%{})
          new_map = Map.put_new(map, key_name, submap) |> Map.drop([options])
          convert_special_keys_to_required_type(tail, new_map)

      "random_json_key_value" ->
        # IO.inspect(map)
        if map["Task Type"] == "IO" || map["Task Type"] == "IM" do
          array =
            String.split(map["Config"], ";")
            |> Enum.filter( fn x -> x != "" end)
            |> Enum.map(fn x ->
                [label, value, raise_ticket] = String.split(x, ":")
                 r_ticket = if raise_ticket in ["TRUE", "True", "true"], do: true, else: false
                %{"label" => label, "value" => value, "raise_ticket" => r_ticket}
              end)
          # new_map = Map.put(map, "Config", %{"options" => array})
          # IO.inspect(new_map)
          new_map = Map.put(map, "Options", array)
          convert_special_keys_to_required_type(tail, new_map)
        else
          if map["Task Type"] == "MT" do
          new_map =
          Map.put(map, "Max Value",  String.to_integer(Map.get(map, "Max Value")))
          |> Map.put("Min Value",   String.to_integer(Map.get(map, "Min Value")))

          convert_special_keys_to_required_type(tail, new_map)
          else
            new_map =
             Map.put(map, "Max Length",   String.to_integer(Map.get(map, "Max Length")))
             |> Map.put("Min Length",   String.to_integer(Map.get(map, "Min Length")))

            convert_special_keys_to_required_type(tail, new_map)
          end


          # if map["Task Type"] == "MT" do
          #   [type, uom] = String.split(Enum.at(map["Config"], 0), ":")
          #   new_map = Map.put(map, "Config", %{"type" => type, "UOM" => uom})
          #   convert_special_keys_to_required_type(tail, new_map)
          # else
          #   [min, max] = String.split(Enum.at(map["Config"], 0), "-") |> Enum.map(fn x -> String.trim(x) |> String.to_integer end)
          #   new_map = Map.put(map, "Config", %{"min_length" => min, "max_length" => max})
          #   # IO.inspect(new_map)
          #   convert_special_keys_to_required_type(tail, new_map)
          # end
        end
      _ ->
         IO.puts("No Type Match")
    end
  end

  def get_records_as_map_for_csv(content, required_fields, array_keys \\ []) do
    {header, data_lines} = get_header_and_data_for_upload_csv(content)

    # header_fields =
    #   String.split(String.trim(header), ",") |> Enum.map(fn fld -> String.trim(fld) end)

    header_fields = header |> Enum.filter(fn x -> if x != "" do String.trim(x) end end)

    if validate_header(header_fields, required_fields) do
      records =
        Enum.map(data_lines, fn data_fields ->

          map =
            if Enum.count(data_fields) > Enum.count(header_fields) do
              zip_and_map(header_fields, data_fields)
            else
              Enum.zip(header_fields, data_fields) |> Enum.into(%{})
            end

          # IO.inspect(map)
          release_map = convert_special_keys_to_required_type(array_keys, map)
          release_map
        end)
      {:ok, records}
    else
      {:error, ["Invalid Header Fields"]}
    end
  end

  def zip_and_map(header_fields, data_fields) do
    {real_data, extra_fields} = Enum.split(data_fields, Enum.count(header_fields))
    new_header_fields = header_fields ++ ["Config"]
    new_data_fields = real_data ++ [extra_fields]
    # IO.inspect(Enum.zip(new_header_fields, new_data_fields) |> Enum.into(%{}))
    Enum.zip(new_header_fields, new_data_fields) |> Enum.into(%{})
  end

  def get_header_and_data_for_upload_csv(content) do
    [header | data_lines] = Path.expand(content.path) |> File.stream!() |> CSV.decode() |> Enum.map(fn {:ok, element} -> element end)
    {header, data_lines}
  end

  defp validate_header(header_fields, required_fields) do
    IO.inspect(header_fields)
    IO.inspect(required_fields)
    IO.inspect(header_fields -- required_fields)
    IO.inspect(required_fields -- header_fields)
    hms = MapSet.new(header_fields)
    rms = MapSet.new(required_fields)
    count = Enum.count(MapSet.intersection(hms, rms))

    count == Enum.count(required_fields)
  end
end

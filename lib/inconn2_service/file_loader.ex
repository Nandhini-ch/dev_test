defmodule Inconn2Service.FileLoader do

  def make_locations(record) do
      %{}
      |> Map.put("name", Map.get(record, "Name"))
      |> Map.put("description", Map.get(record, "Description"))
      |> Map.put("location_code", Map.get(record, "Location Code"))
      |> Map.put("asset_category_id", Map.get(record, "Asset Category Id"))
      |> Map.put("site_id", Map.get(record, "Site Id"))
      |> Map.put("parent_id", Map.get(record, "Parent Id"))
  end

  def make_asset_categories(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("asset_type", Map.get(record, "Asset Type"))
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
  end

  def make_task_lists(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("task_ids", Map.get(record, "Task Ids"))
    |> Map.put("asset_category_id", Map.get(record, "Asset Category Id"))
  end

  def make_checks(record) do
    %{}
    |> Map.put("label", Map.get(record, "Label"))
    |> Map.put("type", Map.get(record, "Type"))
    |> Map.put("check_type_id", Map.get(record, "Check Type Id"))
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

  def make_check_types(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("description", Map.get(record, "Description"))
  end

  def make_workorder_templates(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("asset_category_id", Map.get(record, "Asset Category Id"))
    |> Map.put("asset_type", Map.get(record, "Asset Type"))
    |> Map.put("task_list_id", Map.get(record, "Task List Id"))
    |> Map.put("tasks", Map.get(record, "Tasks"))
    |> Map.put("estimated_time", Map.get(record, "Estimated Time"))
    |> Map.put("scheduled", Map.get(record, "Scheduled"))
    |> Map.put("repeat_every", Map.get(record, "Repeat Every"))
    |> Map.put("repeat_unit", Map.get(record, "Repeat Unit"))
    |> Map.put("applicable_start", Map.get(record, "Applicable Start"))
    |> Map.put("applicable_end", Map.get(record, "Applicable End"))
    |> Map.put("time_start", Map.get(record, "Time Start"))
    |> Map.put("time_end", Map.get(record, "Time End"))
    |> Map.put("create_new", Map.get(record, "Create New"))
    |> Map.put("max_times", Map.get(record, "Max Times"))
    |> Map.put("workorder_prior_time", Map.get(record, "Work Order Prior Time"))
    |> Map.put("workpermit_required", Map.get(record, "Work Permit Required"))
    |> Map.put("Workpermit_check_list_id", Map.get(record, "Work Permit Check List Id"))
    |> Map.put("loto_required", Map.get(record, "Loto Required"))
    |> Map.put("loto_lock_check_list_id", Map.get(record, "Loto Lock Check List Id"))
    |> Map.put("loto_release_check_list_id", Map.get(record, "Loto Release Check List Id"))
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

  def make_tasks(record) do
    %{}
    |> Map.put("label", Map.get(record, "Label"))
    |> Map.put("task_type", Map.get(record, "Task Type"))
    |> Map.put("estimated_time", Map.get(record, "Estimated Time"))
    |> Map.put("master_task_type_id", Map.get(record, "Master Task Type Id"))
    |> Map.put("config", Map.get(record, "Config"))
  end

  def make_employees(record) do
    %{}
    |> Map.put("first_name", Map.get(record, "First Name"))
    |> Map.put("last_name", Map.get(record, "Last Name"))
    |> Map.put("employement_start_date", Map.get(record, "Employment Start Date"))
    |> Map.put("employment_end_date", Map.get(record, "Employment End Date"))
    |> Map.put("designation", Map.get(record, "Designation"))
    |> Map.put("email", Map.get(record, "Email"))
    |> Map.put("employee_id", Map.get(record, "Employee Id"))
    |> Map.put("landline_no", Map.get(record, "Landline No"))
    |> Map.put("mobile_no", Map.get(record, "Mobile No"))
    |> Map.put("salary", Map.get(record, "Salary"))
    |> Map.put("has_login_crendentials", Map.get(record, "Create User?"))
    |> Map.put("reports_to", Map.get(record, "Reports to"))
    |> Map.put("skills", Map.get(record, "Skills"))
    |> Map.put("org_unit_id", Map.get(record, "Org Unit Id"))
    |> Map.put("party_id", Map.get(record, "Party Id"))
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

      "boolean" ->
        value = if map[key_name] == "TRUE", do: true, else: false
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
        IO.inspect(map)
        if map["Task Type"] == "IO" || map["Task Type"] == "IM" do
          array =
            Enum.filter(map["Config"], fn x -> x != "" end)
            |> Enum.map(fn x ->
                [label, value] = String.split(x, ":")
                %{"label" => label, "value" => value}
              end)
          new_map = Map.put(map, "Config", %{"options" => array})
          IO.inspect(new_map)
          convert_special_keys_to_required_type(tail, new_map)
        else
          if map["Task Type"] == "MT" do
            [type, uom] = String.split(Enum.at(map["Config"], 0), ":")
            new_map = Map.put(map, "Config", %{"type" => type, "UOM" => uom})
            convert_special_keys_to_required_type(tail, new_map)
          else
            [min, max] = String.split(Enum.at(map["Config"], 0), "-") |> Enum.map(fn x -> String.trim(x) |> String.to_integer end)
            new_map = Map.put(map, "Config", %{"min_length" => min, "max_length" => max})
            IO.inspect(new_map)
            convert_special_keys_to_required_type(tail, new_map)
          end
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

          IO.inspect(map)
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
    IO.inspect(Enum.zip(new_header_fields, new_data_fields) |> Enum.into(%{}))
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

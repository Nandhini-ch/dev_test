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
  end

  def make_check_lists(record) do
    %{}
    |> Map.put("name", Map.get(record, "Name"))
    |> Map.put("type", Map.get(record, "Type"))
    |> Map.put("check_ids", Map.get(record, "Check Ids"))
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

  def convert_sigil_to_array([], map), do: map

  def convert_sigil_to_array(keys, map) do
    [array_key| tail] = keys
    array_value =
      if map[array_key] == "", do: [], else: String.split(map[array_key], ";") |> Enum.map(fn x -> String.to_integer(x) end)
    new_map = Map.put(map, array_key, array_value)
    convert_sigil_to_array(tail, new_map)
  end

  def convert_special_keys_to_required_type([], map), do: map

  def convert_special_keys_to_required_type(keys, map) do
    [{key_name, type, options} | tail] = keys
    case type do
      "array_of_integers" ->
        array_value =
          if map[key_name] == "", do: [], else: String.split(map[key_name], ";") |> Enum.map(fn x -> String.to_integer(x) end)
          new_map = Map.put(map, key_name, array_value)
        convert_special_keys_to_required_type(tail, new_map
        )
      "integer_array_tuples_with_index" ->
        array_value =
          if map[key_name] == "", do: [], else: String.split(map[key_name], ";") |> Enum.map(fn x -> String.to_integer(x) end) |> Enum.with_index(1) |> Enum.map(fn {v, i} -> %{"id" => v, "order" => i} end)
        new_map = Map.put(map, key_name, array_value)
        convert_special_keys_to_required_type(tail, new_map)

      "date" ->
        [date, month, year] = String.split(map[key_name], "-")
        {:ok, date} = Date.from_iso8601("#{year}-#{month}-#{date}")
        new_map = Map.put(map, key_name, date)
        convert_special_keys_to_required_type(tail, new_map)

      "boolean" ->
        value = if map[key_name] == "TRUE", do: true, else: false
        new_map = Map.put(map, key_name, value)
        convert_special_keys_to_required_type(tail, new_map)

      "map_out_of_existing_options" ->
        submap_value_list =
          Enum.map(options, fn option ->
            map[option]
          end)
          submap = Enum.zip(options, submap_value_list) |> Enum.into(%{})
          new_map = Map.put_new(map, key_name, submap) |> Map.drop([options])
          convert_special_keys_to_required_type(tail, map)
      _ ->
         IO.puts("No Type Match")
    end
  end

  def get_records_as_map_for_csv(content, required_fields, array_keys \\ []) do
    {header, data_lines} = get_header_and_data_for_upload_csv(content)

    header_fields =
      String.split(String.trim(header), ",") |> Enum.map(fn fld -> String.trim(fld) end)

    if validate_header(header_fields, required_fields) do
      records =
        Enum.map(data_lines, fn data_line ->
          data_fields =
            String.split(String.trim(data_line), ",") |> Enum.map(fn v -> String.trim(v) end)

          # convert_sigil_to_array(Enum.zip(header_fields, data_fields) |> Enum.into(%{}), array_keys)
          map = Enum.zip(header_fields, data_fields) |> Enum.into(%{})
          # release_map = convert_sigil_to_array(array_keys, map)
          release_map = convert_special_keys_to_required_type(array_keys, map)
          # IO.puts(map)
          release_map
        end)

      {:ok, records}
    else
      {:error, ["Invalid Header Fields"]}
    end
  end

  def get_header_and_data_for_upload_csv(content) do
    content_lines =
      File.read!(content.path)
      |> String.split("\n")
      |> Enum.filter(fn line ->
        String.length(String.trim(line)) != 0
      end)

    [header | data_lines] = content_lines
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

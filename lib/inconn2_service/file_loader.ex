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

  def convert_sigil_to_array([], map), do: map

  def convert_sigil_to_array(keys, map) do
    [array_key| tail] = keys
    array_value =
      if map[array_key] == "", do: [], else: String.split(map[array_key], ";") |> Enum.map(fn x -> String.to_integer(x) end)
    new_map = Map.put(map, array_key, array_value)
    convert_sigil_to_array(tail, new_map)
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
          release_map = convert_sigil_to_array(array_keys, map)
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
    hms = MapSet.new(header_fields)
    rms = MapSet.new(required_fields)
    count = Enum.count(MapSet.intersection(hms, rms))

    count == Enum.count(required_fields)
  end

end

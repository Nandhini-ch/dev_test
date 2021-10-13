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


  def get_records_as_map_for_csv(content, required_fields) do
    {header, data_lines} = get_header_and_data_for_upload_csv(content)

    
    header_fields =
      String.split(String.trim(header), ",") |> Enum.map(fn fld -> String.trim(fld) end)
    

    if validate_header(header_fields, required_fields) do
      records =
        Enum.map(data_lines, fn data_line ->
          data_fields =
            String.split(String.trim(data_line), ",") |> Enum.map(fn v -> String.trim(v) end)

          Enum.zip(header_fields, data_fields) |> Enum.into(%{})
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

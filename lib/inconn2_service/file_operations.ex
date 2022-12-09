defmodule Inconn2Service.FileOperations do
  def read_file_without_extra_values(content) do
    open_file_stream(content)
    |> CSV.decode!(seperator: ?,, headers: true)
    |> Enum.to_list()
    |> IO.inspect()
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

      "array_of_strings" ->
        array_value =
          if map[key_name] == "", do: [], else: String.split(map[key_name], ",")
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

  defp open_file_stream(content) do
    Path.expand(content.path) |> File.stream!([:trim_bom])
  end
end

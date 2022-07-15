defmodule Inconn2Service.Util.HelpersFunctions do

  def is_date?(date) do
    case Date.from_iso8601(date) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def update_custom_fields(resource, attrs) do
    Map.put(attrs, "custom", merge_custom_values(resource.custom, attrs["custom"]))
  end

  defp merge_cutsom_values(nil, new_map), do: new_map
  defp merge_custom_values(existing_map, nil), do: existing_map
  defp merge_custom_values(existing_map, new_map), do: Map.merge(existing_map, new_map)
end

defmodule Inconn2Service.Util.HelpersFunctions do

  alias Inconn2Service.AssetConfig

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

  def get_success_or_failure_counts(result, status) do
    Enum.count(result, fn {s, _} -> s == status end)
  end

  def get_success_or_failure_list(result, status) when is_atom(status) do
    Keyword.take(result, [status])
    |> Keyword.values()
  end

  def get_site_date_time_now(site_id, prefix) do
    AssetConfig.get_site!(site_id, prefix)
    |> Map.fetch!(:time_zone)
    |> DateTime.now!()
    |> DateTime.to_naive()
  end

  def get_site_date_now(site_id, prefix) do
    AssetConfig.get_site!(site_id, prefix)
    |> Map.fetch!(:time_zone)
    |> DateTime.now!()
    |> DateTime.to_date()
  end

  def get_site_config_for_dashboards(site_id, prefix) do
    case AssetConfig.get_site_config_by_site_id_and_type(site_id, "DASH", prefix) do
      nil -> %{}
      site_config -> site_config.config
    end
  end

  def form_date_list_from_iso(nil, nil, site_id, prefix) do
    to_date = get_site_date_now(site_id, prefix)
    from_date = Date.add(to_date, -30)
    form_date_list(from_date, to_date)
  end

  def form_date_list_from_iso(from_date, to_date, _site_id, _prefix) do
    form_date_list(
      Date.from_iso8601!(from_date),
      Date.from_iso8601!(to_date)
    )
  end

  def form_date_list(from_date, to_date) do
    list = [from_date] |> List.flatten()
    now_date = Date.add(List.last(list), 1)
    case Date.compare(now_date, to_date) do
      :gt ->
            list
      _ ->
            list ++ [now_date]
            |> form_date_list(to_date)
    end
  end

  def change_nil_to_zero(nil), do: 0
  def change_nil_to_zero(data), do: data

  def change_nil_to_one(nil), do: 1
  def change_nil_to_one(data), do: data

  def convert_nil_to_list(nil), do: []
  def convert_nil_to_list(list), do: list

  def convert_string_list_to_list(nil), do: []
  def convert_string_list_to_list(string) do
    String.split(string, ",")
    |> Enum.map(&(String.to_integer(&1)))
  end

end

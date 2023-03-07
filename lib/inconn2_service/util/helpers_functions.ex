defmodule Inconn2Service.Util.HelpersFunctions do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig

  def add_asset_type_to_asset(asset, asset_type) do
    Map.put(asset, :asset_type, asset_type)
  end

  def is_date?(date) do
    case Date.from_iso8601(date) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def convert_date_format(nil) do
    nil
  end

  def convert_date_format(date) do
    "#{date.day}-#{date.month}-#{date.year}"
  end

  def convert_time_format(nil) do
    nil
  end

  def convert_time_format(time) do
    "#{time.hour}:#{time.minute}"
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

  def get_ids_from_query(query, prefix) do
    from(q in query, select: q.id)
    |> Repo.all(prefix: prefix)
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

  def get_yesterday_date(site_id, prefix) do
    get_site_date_now(site_id, prefix)
    |> Date.add(-1)
  end

  def get_yesterday_date_time(site_id, prefix) do
    date = get_yesterday_date(site_id, prefix)
    {
      NaiveDateTime.new!(date, ~T[00:00:00]),
      NaiveDateTime.new!(date, ~T[23:59:59])
    }
  end

  def get_month_date_time_till_now(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)
    {NaiveDateTime.new!(from_date, ~T[00:00:00]), NaiveDateTime.new!(to_date, ~T[23:59:59])}
  end

  def get_month_date_till_now(site_id, prefix) do
    to_date = get_site_date_now(site_id, prefix)
    from_date = Date.new!(to_date.year, to_date.month, 01)
    {from_date, to_date}
  end

  def get_site_date_time(from_date, to_date, site_id, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(from_date, to_date, site_id, prefix)
    {NaiveDateTime.new!(from_date, ~T[00:00:00]), NaiveDateTime.new!(to_date, ~T[23:59:59])}
  end

  def get_from_date_to_date_from_iso(nil, nil, site_id, prefix) do
    site_date = get_site_date_now(site_id, prefix)
    {
      Date.add(site_date, -30),
      site_date
    }
  end

  def get_from_date_to_date_from_iso(from_date, to_date, _site_id, _prefix) do
    {
      Date.from_iso8601!(from_date),
      Date.from_iso8601!(to_date)
    }
  end

  def get_from_date_to_date_from_iso(nil, nil), do: {nil, nil}
  def get_from_date_to_date_from_iso(from_date, to_date) do
    {
      Date.from_iso8601!(from_date),
      Date.from_iso8601!(to_date)
    }
  end

  def get_from_and_to_date_time(nil, nil), do: {nil, nil}
  def get_from_and_to_date_time(from_date, to_date) do
    {from_date_as_date, to_date_as_date} = get_from_date_to_date_from_iso(from_date, to_date)
    {
      NaiveDateTime.new!(from_date_as_date, ~T[00:00:00]),
      NaiveDateTime.new!(to_date_as_date, ~T[00:00:00])
    }
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

  def calculate_percentage(numerator, 0), do: numerator
  def calculate_percentage(numerator, denominator) do
    ((numerator/denominator) * 100)
    |> Float.ceil(2)
  end

  def change_nil_to_zero(nil), do: 0
  def change_nil_to_zero(data), do: data

  def change_nil_to_one(nil), do: 1
  def change_nil_to_one(0), do: 1
  def change_nil_to_one([]), do: 1
  def change_nil_to_one(data), do: data

  def convert_nil_to_list(nil), do: []
  def convert_nil_to_list(list), do: list

  def convert_string_list_to_list(nil), do: []
  # def convert_string_list_to_list(string) when String.length(string)==0, do: [String.to_integer(string)]
  def convert_string_list_to_list(string) do
    String.split(string, ",")
    |> Enum.map(&(String.to_integer(&1)))
  end

  def convert_integer_to_non_neg_integer(integer) when integer < 0, do: integer * -1
  def convert_integer_to_non_neg_integer(integer), do: integer

  def convert_to_hours_and_minutes(value) when is_integer(value) do
    "#{to_string(value)}.0"
    |> convert_to_hours_and_minutes_from_string()
  end

  def convert_to_hours_and_minutes(value) when is_float(value) do
    to_string(value)
    |> convert_to_hours_and_minutes_from_string()
  end

  def convert_to_hours_and_minutes_from_string(string) do
    [hours, decimal] = String.split(string, ".")

   hours = String.to_integer(hours)
   hours = if hours < 10 do
             "#{"0" <> Integer.to_string(hours)}"
           else
             "#{Integer.to_string(hours)}"
           end

   minutes = String.to_float("0." <> decimal)
   minutes = minutes * 60 |> trunc()
   minutes = if minutes < 10 do
               "#{"0" <> Integer.to_string(minutes)}"
             else
               "#{Integer.to_string(minutes)}"
             end

  "#{hours} : #{minutes}"
  end

  def string_to_float(""), do: 0.0
  def string_to_float(nil), do: 0.0
  def string_to_float(number) when is_float(number), do: number
  def string_to_float(number) when is_integer(number), do: number + 0.0
  def string_to_float(number) when is_bitstring(number) do
    if String.contains?(number, ".") do
      String.to_float(number)
    else
      String.to_integer(number) + 0.0
    end
  end

  def convert_to_float(number) when is_float(number), do: number
  def convert_to_float(number), do: number * 1.0

  def get_backend_url(sub_domain) do
    case Application.get_env(:inconn2_service, :environment) do
      :prod -> "https://#{sub_domain}.inconn.io:4001"
      :dev -> "http://#{sub_domain}.inconn.com:4000"
    end
  end

  def get_frontend_url(sub_domain) do
    case Application.get_env(:inconn2_service, :environment) do
      :prod -> "https://#{sub_domain}.inconn.io:443"
      :dev -> "http://#{sub_domain}.inconn.com:8080"
    end
  end
end

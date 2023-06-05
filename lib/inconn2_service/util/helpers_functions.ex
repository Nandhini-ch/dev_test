defmodule Inconn2Service.Util.HelpersFunctions do

  import Ecto.Query, warn: false
  alias Inconn2Service.Staff
  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig

  def add_asset_type_to_asset(asset, asset_type) do
    Map.put(asset, :asset_type, asset_type)
  end

  def convert_string_ids_to_list_of_ids(string_ids) do
    string_ids
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
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
    |> NaiveDateTime.truncate(:second)
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

  def get_year_to_date_time(site_id, prefix) do
    date = get_site_date_now(site_id, prefix)
    year_start_date = Date.new!(date.year, 01, 01)
    {
      NaiveDateTime.new!(year_start_date, ~T[00:00:00]),
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

  def get_from_time_to_time_from_iso(nil, nil), do: {~T[00:00:00], ~T[23:59:59]}
  def get_from_time_to_time_from_iso(from_time, to_time) do
    {
      Time.from_iso8601!(from_time),
      Time.from_iso8601!(to_time)
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

  def get_date_time_range_for_date_and_time_range(date, from_time, to_time) do
    case Time.compare(from_time, to_time) do
      :gt ->
        { NaiveDateTime.new!(date, from_time), NaiveDateTime.new!(Date.add(date, 1), to_time) }

      _ ->
        { NaiveDateTime.new!(date, from_time), NaiveDateTime.new!(date, to_time) }

    end
  end

  def form_date_time_list_tuple_from_time_range_from_iso(nil, nil, date) do
    form_date_time_list_tuple_from_time_range(
      ~T[00:00:00],
      ~T[23:59:59],
      Date.from_iso8601!(date)
      )
  end

  def form_date_time_list_tuple_from_time_range_from_iso(from_time, to_time, date) do
    form_date_time_list_tuple_from_time_range(
      Time.from_iso8601!(from_time),
      Time.from_iso8601!(to_time),
      Date.from_iso8601!(date)
      )
  end

  def form_date_time_list_tuple_from_time_range(from_time, to_time, date) do
    case Time.compare(from_time, to_time) do
      :gt ->
        from_dt = NaiveDateTime.new!(date, from_time)
        to_dt = NaiveDateTime.new!(Date.add(date, 1), to_time)
        form_date_time_tuple_list(from_dt, to_dt)

      _ ->
        from_dt = NaiveDateTime.new!(date, from_time)
        to_dt = NaiveDateTime.new!(date, to_time)
        form_date_time_tuple_list(from_dt, to_dt)

    end
  end

  defp form_date_time_tuple_list(from_dt, to_dt) do
    dt_list = form_naive_date_time_list(from_dt, to_dt) |> IO.inspect()
    last_dt = Enum.at(dt_list, length(dt_list) - 1)
    neg_diff = Time.diff(last_dt, to_dt)

    tuple_list = Enum.map(dt_list, fn dt ->
      {
        NaiveDateTime.add(dt, -3599),
        dt,
        NaiveDateTime.to_time(dt)
      }
    end)

    if neg_diff == 0 do
      tuple_list
    else
      tuple_list ++
      [
        {
          NaiveDateTime.add(to_dt, neg_diff + 1),
          to_dt,
          NaiveDateTime.to_time(to_dt)
        }
      ]
    end
  end

  def form_naive_date_time_list(from_dt, to_dt) do
    list = [from_dt] |> List.flatten()
    now_dt = NaiveDateTime.add(List.last(list), 3600)
    case NaiveDateTime.compare(now_dt, to_dt) do
      :gt ->
            list
      _ ->
            list ++ [now_dt]
            |> form_naive_date_time_list(to_dt)
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

  def calculate_percentage(numerator, 0), do: numerator
  def calculate_percentage(numerator, denominator) do
    ((numerator/denominator) * 100)
    |> convert_to_ceil_float()
  end

  def change_nil_to_zero(nil), do: 0
  def change_nil_to_zero(data), do: data

  def change_nil_to_one(nil), do: 1
  def change_nil_to_one(0), do: 1
  def change_nil_to_one([]), do: 1
  def change_nil_to_one(data), do: data

  def convert_nil_to_list(nil), do: []
  def convert_nil_to_list(list), do: list

  def convert_nil_to_map(nil), do: %{}
  def convert_nil_to_map(map), do: map

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
      :pre_prod -> "https://#{sub_domain}.inconn.com:4001"
      :dev -> "http://#{sub_domain}.inconn.in:4000"
    end
  end

  def get_frontend_url(sub_domain) do
    case Application.get_env(:inconn2_service, :environment) do
      :prod -> "https://#{sub_domain}.inconn.io:443"
      :pre_prod -> "https://#{sub_domain}.inconn.com:443"
      :dev -> "http://#{sub_domain}.inconn.in:8080"
    end
  end

  def convert_to_ceil_float(value) when is_float(value), do: Float.ceil(value, 2)

  def convert_to_ceil_float(value), do: value

  def convert_float_to_binary(value) when is_float(value), do: Float.ceil(value) |> :erlang.float_to_binary([ decimals: 2])

  def convert_float_to_binary(value), do: value

  def naming_conversion(nil), do: ""
  def naming_conversion(string) do
    string
    |> String.replace(~r/\s+/, "_")
    |> String.downcase()
  end

  def convert_list_from_query_params(nil), do: []
  def convert_list_from_query_params(string) do
    string
    |> String.split(",")
    |> Enum.map(&(String.to_integer/1))
  end

  def form_message_text_from_template(message_template, list_of_values) do
    key_value =
      Enum.reduce(list_of_values, [], fn value, acc ->
        [{"var#{length(acc) + 1}" |> String.to_atom, value} | acc]
      end)
      IO.inspect(key_value)

    EEx.eval_string(message_template, key_value)

  end

  def get_display_name_for_user_id(nil, _prefix), do: ""
  def get_display_name_for_user_id(user_id, prefix) do
    user = Staff.get_user!(user_id, prefix)
    "#{user.first_name} #{user.last_name}"
  end

end

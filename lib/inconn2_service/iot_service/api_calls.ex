defmodule Inconn2Service.IotService.ApiCalls do
  @base_url "http://localhost:5000/api/inconn"

  def asset_ids_of_meters_and_sensors(site_id, prefix) do
    get_request(
      @base_url <> "/asset_ids_of_meters_and_sensors",
      %{licensee_prefix: prefix, site_id: site_id})
  end

  def get_energy_consumption_for_asset(asset_id, asset_type, from_dt, to_dt, prefix) do
    "inc_" <> sub_domain = prefix
    params =
      %{
        "asset_id" => asset_id,
        "asset_type" => asset_type,
        "from_dt" => from_dt,
        "to_dt" => to_dt,
        "licensee_prefix" => sub_domain
      }

    get_request(@base_url <> "/energy_meter_reading", params)
  end

  defp get_request(url, params) do
    headers = ["Accept": "Application/json; Charset=utf-8"]
    {:ok, response} = HTTPoison.get(url, headers, [params: params])
    body = Jason.decode!(response.body)
    body["data"]
  end
end

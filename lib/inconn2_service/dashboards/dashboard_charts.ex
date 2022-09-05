defmodule Inconn2Service.Dashboards.DashboardCharts do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.NumericalData

  def get_energy_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"])

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  defp get_individual_energy_consumption_data(date, params, prefix) do
    value =
      NumericalData.get_energy_consumption_for_site(
                      params["site_id"],
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

    %{
      date: date,
      dataSets: [
        %{
          name: "Energy Consumption",
          value: value
        }
      ]
    }
  end

end

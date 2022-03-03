defmodule Inconn2Service.Dashboards do

  def get_energy_meter_speedometer_random(_query_parmas, _params) do
    %{
      labels: ["Site Name"],
      data: [Enum.random(100..1000)]
    }
  end

  def get_energy_meter_linear_chart_random(query_params, _prefix) do
    {from_date, to_date} =
            case query_params do
              %{"from_date" => from_date,  "to_date" => to_date} ->
                converted_from_date = Date.from_iso8601!(from_date)
                converted_to_date = Date.from_iso8601!(to_date)
                {converted_from_date, converted_to_date}

              %{"from_date" => from_date} ->
                converted_from_date = Date.from_iso8601!(from_date)
                {converted_from_date, Date.utc_today()}

              _ ->
                {Date.utc_today, Date.utc_today}
            end
    date_list = form_date_list(from_date, to_date)

    random =
      case query_params["type"] do
        "EC" -> 1..1000
        "EPI" -> 1..10
        "DEVI" -> -10..10
        "TOP3" ->  1..100
        _ -> 1..100
      end
    cost = Enum.random(5..30)
    data1 = Enum.map(1..length(date_list), fn _x -> Enum.random(random) end)
    data2 = Enum.map(1..length(date_list), fn _x -> Enum.random(random) end)
    data3 = Enum.map(1..length(date_list), fn _x -> Enum.random(random) end)

    avg_value1 = Enum.sum(data1) / length(data1)
    avg_value2 = Enum.sum(data2) / length(data2)
    avg_value3 = Enum.sum(data3) / length(data3)
    case query_params["type"] do
      "TOP3" ->
          %{
            labels: date_list,
            datasets: [
              %{
                data: data1, label: "Asset 1", avg_value: avg_value1, cost: avg_value1 * cost
              },
              %{
                data: data2, label: "Asset 2", avg_value: avg_value2, cost: avg_value2 * cost
              },
              %{
                data: data3, label: "Asset 3", avg_value: avg_value3, cost: avg_value3 * cost
              }
            ]
          }
      _ ->
        %{
          labels: date_list,
          datasets: [
            %{
              data: data1, label: "Asset", avg_value: avg_value1
            }
          ]
        }
    end
  end

  defp form_date_list(from_date, to_date) do
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
end

defmodule Inconn2Service.Dashboard do

  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.Workorder.WorkOrder

  def work_order_pie_chart(prefix, query_params) do
    date = Date.utc_today()
    query =
      case query_params do
        %{"from_date" => from_date,  "to_date" => to_date} ->
          converted_from_date = date_convert(from_date)
          converted_to_date = date_convert(to_date)
          from wo in WorkOrder, where: wo.scheduled_date >= ^converted_from_date and wo.scheduled_date <= ^converted_to_date

        %{"from_date" => from_date} ->
          converted_from_date = date_convert(from_date)
          from wo in WorkOrder, where: wo.scheduled_date >= ^converted_from_date and wo.scheduled_date <= ^date

        _ ->
          from wo in WorkOrder, where: wo.scheduled_date == ^date
      end

    work_orders = Repo.all(query, prefix: prefix)
    completed_work_order_count = Enum.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
    incomplete_work_order_count = Enum.filter(work_orders, fn wo -> wo.status != "cp" end) |> Enum.count()

    %{completed_work_order_count: completed_work_order_count, incomplete_work_order_count: incomplete_work_order_count}
  end

  def work_order_bar_chart(prefix, query_params) do
    date = Date.utc_today()
    query =
      case query_params do
        %{"from_date" => from_date,  "to_date" => to_date} ->
          converted_from_date = date_convert(from_date)
          converted_to_date = date_convert(to_date)
          from wo in WorkOrder, where: wo.scheduled_date >= ^converted_from_date and wo.scheduled_date <= ^converted_to_date

        %{"from_date" => from_date} ->
          converted_from_date = date_convert(from_date)
          from wo in WorkOrder, where: wo.scheduled_date >= ^converted_from_date and wo.scheduled_date <= ^date

        _ ->
          from wo in WorkOrder, where: wo.scheduled_date == ^date
      end
    work_orders = Repo.all(query, prefix: prefix) |> Enum.group_by(&(&1.scheduled_date))

    completed_work_order_counts =
      Enum.map(work_orders, fn{_date, work_orders} ->
        Enum.filter(work_orders, fn work_order -> work_order.status == "cp" end) |> Enum.count
      end)

    incomplete_work_order_counts =
      Enum.map(work_orders, fn{_date, work_orders} ->
        Enum.filter(work_orders, fn work_order -> work_order.status != "cp" end) |> Enum.count
      end)


    %{
      completed_work_order_count: completed_work_order_counts,
      incomplete_work_order_count: incomplete_work_order_counts,
      dates: Map.keys(work_orders)
    }
  end

  defp date_convert(date_to_convert) do
    date_to_convert
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> (fn [year, month, day] -> Date.new(year, month, day) end).()
  end
end

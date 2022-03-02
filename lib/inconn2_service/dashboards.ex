defmodule Inconn2Service.Dashboards do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Ticket.WorkRequest

  def work_flow_linear_chart(prefix, query_params) do

  end

  def ticket_linear_chart(prefix, query_params) do
    main_query = from wo in WorkOrder, where: wo.type == "TKT",
    join: wr in WorkRequest, on: wo.id == wr.work_order_id

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"asset_category_id", asset_category_id}, main_query ->
          asset_ids = asset_ids_for_asset_category(asset_category_id, prefix)
          asset_category = AssetConfig.get_asset_category(asset_category_id, prefix)
          case query_params["asset_id"] do
            nil ->
              from q in main_query, where: q.asset_id in ^asset_ids and q.asset_type == ^asset_category.asset_type

            id ->
              from q in main_query, where: q.asset_id == ^id and q.asset_type == ^asset_category.asset_type
          end

        {"site_id", site_id}, main_query ->
           from q in main_query, where: q.site_id == ^site_id
      end)

      {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)

      work_orders =
        from(q in dynamic_query, where: q.scheduled_date >= ^from_date and q.scheduled_date <= ^to_date)
        |> Repo.all(prefix: prefix)

      open_ticket_count = Enum.filter(work_orders, fn wo -> wo.work_request.status not in ["CL", "CS"] end)
      closed_ticket_count = Enum.filter(work_orders, fn wo -> wo.work_request.status in ["CL", "CS"] end)
      %{
        labels: ["Open Ticket Count", "Closed Ticket Count"],
        datasets: [open_ticket_count, closed_ticket_count],
        total_count: Enum.count(work_orders)
      }
  end

  defp get_dates_for_query(nil, nil, site_id, prefix) do
    site = AssetConfig.get_site!(site_id, prefix)
    {
      DateTime.now!(site.time_zone) |> DateTime.to_date() |> Date.add(-1),
      DateTime.now!(site.time_zone) |> DateTime.to_date() |> Date.add(-1)
    }
  end

  defp get_dates_for_query(from_date, nil, site_id, prefix) do
    site = AssetConfig.get_site!(site_id, prefix)
    {
      Date.from_iso8601!(from_date),
      DateTime.now!(site.time_zone) |> DateTime.to_date() |> Date.add(-1)
    }
  end

  defp get_dates_for_query(from_date, to_date, _site_id, _prefix) do
    {Date.from_iso8601!(from_date), Date.from_iso8601!(to_date)}
  end

  defp asset_ids_for_asset_category(asset_category_id, prefix) do
    AssetConfig.get_assets_by_asset_category_id(asset_category_id, prefix)
    |> Enum.map(fn a -> a.id end)
  end
end

defmodule Inconn2Service.Report do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.Staff.User
  alias Inconn2Service.Staff.Employee
  alias Inconn2Service.Inventory.Item
  alias Inconn2Service.AssetConfig.Location
  alias Inconn2Service.AssetConfig.Equipment

  def get_work_order_report(prefix) do
    query = from w in WorkOrder,
            join: wt in WorkorderTemplate, on: wt.id == w.workorder_template_id,
            join: u in User, on: u.id == w.user_id,
            select: { w.type, w.status, wt.spares, w.start_time, w.completed_time, w.asset_id, wt.asset_type, u.username }
    work_orders = Repo.all(query, prefix: prefix)

    header = "<table border=1><tr><th>Asset Name</th><th>Asset Code</th><th>WO Category</th><th>Status</th><th>Assigned To</th><th>Spares Consumed</th></tr>"


    data = Enum.map(work_orders, fn work_order ->

      # manhours_consumed = elem(work_order, 4) - elem(work_order, 4)

      {asset_name, asset_code} =
        case elem(work_order, 6) do
          "L" ->
            asset = Repo.get!(Location, elem(work_order, 5), prefix: prefix)
            {asset.name, asset.location_code}

          "E" ->
            asset = Repo.get!(Equipment, elem(work_order, 5), prefix: prefix)
            {asset.name, asset.equipment_code}
        end

      {rowspan, first_spare, spares_row} =
        case get_items_for_report(elem(work_order, 2), prefix) do
        [] ->
          {1, "", ""}

        list_of_spares ->
          [first_spare | spares] = list_of_spares
          rowspan = length(list_of_spares)
          spares_row = Enum.map(spares, fn s->
            "<tr><td>#{s}</td></tr>"
          end) |> Enum.join()
          {rowspan, first_spare, spares_row}
        end

      "<tr><td rowspan=#{rowspan}>#{asset_name}</td><td rowspan=#{rowspan}>#{asset_code}</td><td rowspan=#{rowspan}>#{elem(work_order, 0)}</td><td rowspan=#{rowspan}>#{elem(work_order, 1)}</td><td rowspan=#{rowspan}>#{elem(work_order, 7)}</td><td>#{first_spare}</td></tr>" <> spares_row
    end) |> Enum.join()

    IO.inspect(header <> data)

    PdfGenerator.generate(header <> data <> "</table>", page_size: "A3")
  end


  def get_items_for_report(tools_list, prefix) do
    Enum.map(tools_list, fn t->
      item = Repo.get(Item, t["id"], prefix: prefix)
      ~s(#{item.name}-#{t["quantity"]})
    end)
  end


  def create_rowspan_columns([]), do: []
end

defmodule Inconn2Service.Report do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.Staff.User
  alias Inconn2Service.Staff.Employee
  alias Inconn2Service.Inventory.Item

  def get_work_order_report(prefix) do
    query = from w in WorkOrder,
            join: wt in WorkorderTemplate, on: wt.id == w.workorder_template_id,
            # join: u in User, on: u.id == w.user_id,
            select: { w.type, w.status, wt.spares, w.start_time, w.completed_time }
    work_orders = Repo.all(query, prefix: prefix)

    header = "<table border=1><tr><th>WO Category</th><th>Status</th><th>Spares Consumed</th></tr>"


    data = Enum.map(work_orders, fn work_order ->
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

      "<tr><td rowspan=#{rowspan}>#{elem(work_order, 0)}</td><td rowspan=#{rowspan}>#{elem(work_order, 1)}</td><td>#{first_spare}</td></tr>" <> spares_row
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

defmodule Inconn2Service.Report do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.Staff.User
  alias Inconn2Service.Inventory
  # alias Inconn2Service.Staff.Employee
  # alias Inconn2Service.Inventory.Item
  # alias Inconn2Service.AssetConfig.Location
  # alias Inconn2Service.AssetConfig.Equipment


  def get_work_order_report(prefix) do
    query = from w in WorkOrder,
            join: wt in WorkorderTemplate, on: wt.id == w.workorder_template_id,
            join: u in User, on: u.id == w.user_id,
            select: { w.type, w.status, wt.spares, w.start_time, w.completed_time, w.asset_id, wt.asset_type, u.username }

    work_orders = Repo.all(query, prefix: prefix)


    Enum.map(work_orders, fn work_order ->

      asset =
        case elem(work_order, 6) do
          "L" ->
            location = Inconn2Service.AssetConfig.get_location!(elem(work_order, 5), prefix)
            %{name: location.name, type: "Location", code: location.location_code}
          "E" ->
            equipment = Inconn2Service.AssetConfig.get_equipment!(elem(work_order, 5), prefix)
            %{name: equipment.name, type: "Equipment", code: equipment.equipment_code}
        end

        spares =
          Enum.map(elem(work_order, 2), fn s ->
            spare = Inventory.get_item!(s["id"], prefix)
            uom = Inventory.get_uom!(s["uom_id"], prefix)
            %{name: spare.name, uom: uom.symbol, quantity: s["quantity"]}
          end)


      %{
        work_order_type: elem(work_order, 0),
        work_order_status: elem(work_order, 1),
        spares_consumed: spares,
        start_time: elem(work_order, 3),
        completed_time: elem(work_order, 4),
        asset_name: asset.name,
        asset_code: asset.code,
        asset_type: asset.type,
        employee_user_name: elem(work_order, 7),
      }
    end)

  end
end

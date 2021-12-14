defmodule Inconn2Service.Report do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.Workorder.{WorkOrder, WorkorderTemplate, WorkorderStatusTrack}
  alias Inconn2Service.Staff.User
  alias Inconn2Service.{Inventory, Staff}
  alias Inconn2Service.Inventory.{Item, InventoryLocation, InventoryStock, Supplier, UOM, InventoryTransaction}

  def work_order_report(prefix) do
    query = from w in WorkOrder,
            join: wt in WorkorderTemplate, on: wt.id == w.workorder_template_id,
            join: u in User, on: u.id == w.user_id,
            select: { w.type, w.status, wt.spares, w.start_time, w.completed_time, w.asset_id, wt.asset_type, u.id, w.id }

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

        user = Staff.get_user!(elem(work_order, 7), prefix)

        # query = from(w in WorkorderStatusTrack,
        #              where: w.work_order_id == ^elem(work_order, 8),
        #                     order_by: [desc: w.inserted_at], limit: 1)

        query = from(w in WorkorderStatusTrack,
                    where: w.work_order_id == ^elem(work_order, 8),
                    order_by: [desc: w.inserted_at], limit: 1)


        status_track = Repo.one(query, prefix: prefix)

        # status_track = Repo.get_by(query, prefix: prefix)

        assignee =
          case status_track.status do
            "as" ->
              user = Staff.get_user!(status_track.assigned_from, prefix)
              user.employee.first_name <> " " <> user.employee_last_name

            "reassigned" ->
              user = Staff.get_user!(status_track.assigned_from, prefix)
              user.employee.first_name <> " " <> user.employee_last_name

            _ ->
              ""
          end

      %{
        work_order_type: elem(work_order, 0),
        work_order_status: elem(work_order, 1),
        spares_consumed: spares,
        start_time: elem(work_order, 3),
        completed_time: elem(work_order, 4),
        asset_name: asset.name,
        asset_code: asset.code,
        asset_type: asset.type,
        employee_name: user.employee.first_name <> " " <> user.employee.last_name,
        assignee: assignee
      }
    end)

  end

  def inventory_report(prefix) do
    query = from it in InventoryTransaction,
            join: i in Item, on: i.id == it.item_id,
            join: st in InventoryStock, on: st.item_id == i.id,
            join: u in UOM, on: u.id == it.uom_id,
            join: il in InventoryLocation, on: st.inventory_location_id == il.id,
            join: s in Supplier, on: s.id == it.supplier_id,
            select: { i.name, i.type, i.asset_categories_ids, st.quantity, it.quantity, i.reorder_quantity, u.symbol, il.name, i.aisle, i.bin, i.row, it.cost, s.name, it.transaction_type }

    inventory_items = Repo.all(query, prefix: prefix)

    Enum.map(inventory_items, fn inventory_item ->
      %{
        item_name: elem(inventory_item, 0),
        item_type: elem(inventory_item, 1),
        asset_categories: elem(inventory_item, 2),
        quantity_held: elem(inventory_item, 3),
        transaction_quantity: elem(inventory_item, 4),
        reorder_level: elem(inventory_item, 5),
        uom: elem(inventory_item, 6),
        store_name: elem(inventory_item, 7),
        aisle: elem(inventory_item, 8),
        bin: elem(inventory_item, 9),
        row: elem(inventory_item, 10),
        cost: elem(inventory_item, 11),
        supplier: elem(inventory_item, 12),
        transaction_type: elem(inventory_item, 13)
      }
    end)
  end
end

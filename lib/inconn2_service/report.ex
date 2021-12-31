defmodule Inconn2Service.Report do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig.Location
  alias Inconn2Service.Workorder.{WorkOrder, WorkorderTemplate, WorkorderStatusTrack, WorkorderTask}
  alias Inconn2Service.Ticket.{WorkRequest, WorkrequestStatusTrack, WorkrequestSubcategory}
  alias Inconn2Service.Staff.{User, Employee}
  alias Inconn2Service.{Inventory, Staff}
  alias Inconn2Service.Inventory.{Item, InventoryLocation, InventoryStock, Supplier, UOM, InventoryTransaction}

  def put_sr_no(list) do
    IO.inspect(list)
    Enum.with_index(list, 1) |> Enum.map(fn {v, i} -> "<tr/><td>" <> Integer.to_string(i) <> "</td>" <> v end)
  end

  def ppm_report_query(%{"from_date" => from_date, "to_date" => to_date}, prefix) do
    query = from w in WorkOrder, where: w.type == "PRV" and w.start_date >= ^from_date or w.completed_date <= ^from_date and w.start_date >= ^to_date or w.completed_date <= ^to_date,
            join: wt in WorkorderTemplate, on: wt.id == w.workorder_template_id,
            select: %{
              wo_type: w.type,
              status: w.status,
              spares: wt.spares,
              start_date: w.start_date,
              scheduled_date: w.scheduled_date,
              scheduled_time: w.scheduled_time,
              completed_date: w.completed_date,
              asset_id: w.asset_id,
              asset_type: wt.asset_type,
              start_time: w.start_time,
              completed_time: w.completed_time,
              status: w.status,
              user_id: w.user_id,
              id: w.id }

    work_orders = Repo.all(query, prefix: prefix) |> Enum.uniq

    heading = ~s(<table border=1px solid black style="border-collapse: collapse" width="100%"><tr><th>SI. No</th><th>Asset Name</th><th>Asset Details</th><th>Status</th><th>Planned Date & Time</th><th>Actual Start Date & Time</th><th>Completed Date & Time</th><th>Assigned User</th></tr>)

    data =
      Enum.map(work_orders, fn w ->

        asset =
          case w.asset_type do
            "L" ->
              location = Inconn2Service.AssetConfig.get_location!(w.asset_id, prefix)
              %{name: location.name, type: "Location", code: location.location_code, description: location.description}

            "E" ->
              equipment = Inconn2Service.AssetConfig.get_equipment!(w.asset_id, prefix)
              location = Inconn2Service.AssetConfig.get_location!(equipment.location_id, prefix)
              %{name: equipment.name, type: "Equipment", code: equipment.equipment_code, description: "Eqiupment prsent in " <> location.name}
          end

          user = Repo.get(User, w.user_id, prefix: prefix) |> Repo.preload(:employee)
          assigned_user =
            case user.employee do
              nil -> user.username
              _ -> user.employee.first_name
            end

        "<td>#{asset.name}</td><td>#{asset.description}</td><td>#{w.status}</td><td>#{w.scheduled_date}, #{w.scheduled_time}</td><td>#{w.start_date}, #{w.start_time}</td><td>#{w.completed_date}, #{w.completed_time}</td><td>#{assigned_user}</td></tr>"

    end) |> put_sr_no() |> Enum.join

    IO.inspect(data)

    {:ok, filename} = PdfGenerator.generate(report_heading("Workorder Preventive maintainance Report") <> heading <> data <> "</table>", page_size: "A4")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def complaints_report(prefix) do
    work_request =
      WorkRequest
      |> where(request_type: ^"CO")
      |> Repo.all(prefix: prefix)
      |> Repo.preload([requested_user: :employee, assigned_user: :employee])
      |> Repo.preload([:workrequest_subcategory])

    heading = ~s(<table border=1px solid black style="border-collapse: collapse" width="100%"><th>SI.No</th><th>Date</th><th>Time</th><th>Given By</th><th>Attended By</th><th>Response Time</th><th>Reason</th><th>ActionTaken</th><th>Close Time</th><th>Complaint type</th><th>Complaint Status</th><th>Time Taken</th>)

    data =
      Enum.map(work_request, fn w ->
        requested_user = get_name_from_user(w.requested_user)
        assigned_user = get_name_from_user(w.assigned_user)

        raised_status = get_work_request_status_track_for_type(w.id, "RS", prefix)
        created_time = raised_status.status_update_time

        response_time =
          case get_work_request_status_track_for_type(w.id, "AS", prefix) do
             nil -> "not yet attended"
             status_track ->
              Time.diff(created_time, status_track.status_update_time, :minute)
          end

        completion_time =
          case get_work_request_status_track_for_type(w.id, "CL", prefix) do
            nil -> "not yet attended"
            status_track ->
              status_track.updated_status_tome
          end

        completion_time_taken =
          case get_work_request_status_track_for_type(w.id, "CL", prefix) do
            nil -> "not yet complete"
            status_track ->
              Time.diff(created_time, status_track.status_update_time, :minute)
          end

          "<td>#{raised_status.status_update_date}</td><td>#{created_time}</td><td>#{requested_user}</td><td>#{assigned_user}</td><td>#{response_time}</td><td>#{w.reason}</td><td>#{w.action_taken}</td><td>#{completion_time}</td><td>#{w.workrequest_subcategory.name}</td><td>#{w.status}</td><td>#{completion_time_taken}</td></tr>"
      end)  |> put_sr_no() |> Enum.join

      IO.inspect(data)

      {:ok, filename} = PdfGenerator.generate(report_heading("Complaint Reports") <> heading <> data <> "</table>", page_size: "A4")
      {:ok, pdf_content} = File.read(filename)
      pdf_content
  end

  def generate_qr_code_for_assets(site_id, prefix) do
    locations_qr = Inconn2Service.AssetConfig.list_locations_qr(site_id, prefix)

    body =
      Enum.map(locations_qr, fn x ->
        "inc_" <> sub_domain = prefix
        IO.inspect("http://#{sub_domain}.localhost:4000#{x.asset_qr_url}")
        ~s(<div class="col-4"><img src="#{sub_domain}.localhost:4000#{x.asset_qr_url}" height="200px" width="200px"/><h3>#{x.asset_name}</h3></div>)
      end) |> Enum.join()

    IO.inspect(body)

    {:ok, filename} = PdfGenerator.generate( ~s(<div class="row">) <> body <> "</div>", page_size: "A4", shell_params: ["--enable-local-file-access"])
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def csg_workorder_report(prefix) do
    date = Date.utc_today |> Date.add(-1)

    heading = ~s(<table border=1px solid black style="border-collapse: collapse" width="100%"><th></th><th></th><th>7:00</th><th>8:00</th><th>9:00</th><th>10:00</th><th>11:00</th><th>12:00</th><th>13:00</th><th>14:00</th><th>15:00</th><th>16:00</th><th>17:00</th><th>18:00</th>)

    work_order_groups = WorkOrder |> Repo.all(prefix: prefix) |> Enum.group_by(&(&1.asset_id))
    IO.inspect(work_order_groups)

    data =
      Enum.map(work_order_groups, fn {_key, work_orders} ->
        # asset = Repo.get(Location, key)
        work_order_template = Repo.get(WorkorderTemplate, List.first(work_orders).workorder_template_id, prefix: prefix)
        complete_status_string =
          Enum.map(work_orders, fn w ->
            case w.status do
              "cp" -> "Y"
              _ -> "N"
            end
          end) |> Enum.join("<td>")
        "<td>" <> work_order_template.name <> "</td><td>" <> complete_status_string <> "</tr>"
      end) |> put_sr_no() |> Enum.join()

      remarks_data =
        Enum.map(work_order_groups, fn {_key, work_orders} ->
          # asset = Repo.get(Location, key)
          work_order_template = Repo.get(WorkorderTemplate, List.first(work_orders).workorder_template_id, prefix: prefix)
          complete_status_string =
            Enum.map(work_orders, fn w ->
              tasks = WorkorderTask |> where([work_order_id: ^w.id]) |> Repo.all(prefix: prefix)
              Enum.map(tasks, fn t -> t.remarks end) |> Enum.join(",")
            end) |> Enum.join("<td>")
          "<td>" <> work_order_template.name <> "</td><td>" <> complete_status_string <> "</tr>"
        end) |> put_sr_no() |> Enum.join()

    IO.inspect(data)

    {:ok, filename} = PdfGenerator.generate(report_heading("Work order completion reports") <> heading <> data <>  ~s(</table>) <> ~s(<div style="page-break-before: always">)<> report_heading("Work order remarks generated") <> heading <> remarks_data <> "</table>", page_size: "A4", shell_params: ["--orientation", "landscape"])
    {:ok, pdf_content} = File.read(filename)
    pdf_content

  end

  def get_work_request_status_track_for_type(work_request_id, status, prefix) do
    Repo.get_by(WorkrequestStatusTrack, [work_request_id: work_request_id, status: status], prefix: prefix)
  end



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

  def report_heading(heading) do
    "<center><h1>#{heading}</h1></center>"
  end

  def get_name_from_user(user) do
    case user.employee do
      nil -> user.username
      _ -> user.employee.first_name
    end
  end
end

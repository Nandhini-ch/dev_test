defmodule Inconn2Service.Report do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Equipment
  alias Inconn2Service.AssetConfig.AssetStatusTrack
  alias Inconn2Service.AssetConfig.Location
  alias Inconn2Service.Workorder.{WorkOrder, WorkorderTemplate, WorkorderStatusTrack, WorkorderTask}
  alias Inconn2Service.Workorder
  alias Inconn2Service.Ticket.{WorkRequest, WorkrequestStatusTrack, WorkrequestSubcategory}
  alias Inconn2Service.Staff.{User, Employee}
  alias Inconn2Service.{Inventory, Staff}
  alias Inconn2Service.Inventory.{Item, InventoryLocation, InventoryStock, Supplier, UOM, InventoryTransaction}



  def work_status_report(prefix, query_params) do
    query_params = rectify_query_params(query_params)

    main_query =
      from wo in WorkOrder,
      left_join: u in User, on: wo.user_id == u.id,
      left_join: e in Employee, on: u.employee_id == e.id,
      select: %{
        site_id: wo.site_id,
        asset_id: wo.asset_id,
        asset_type: wo.asset_type,
        type: wo.type,
        status: wo.status,
        assigned_to: e.first_name,
        start_time: wo.start_time,
        completed_time: wo.completed_time,
        username: u.username,
        first_name: e.first_name,
        last_name: e.last_name,
        workorder_template_id: wo.workorder_template_id
      }


    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"asset_id", asset_id}, main_query ->
          from q in main_query, where: q.asset_id == ^asset_id and q.asset_type == ^query_params["asset_type"]

        {"status", status}, main_query ->
          from q in main_query, where: q.status == ^status

        {"user_id", user_id}, main_query ->
          from q in main_query, where: q.user_id == ^user_id

        _, main_query ->
          main_query
      end)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)

    query_with_dates = from dq in dynamic_query, where: dq.scheduled_date >= ^from_date and dq.scheduled_date <= ^to_date


    work_orders = Repo.all(query_with_dates, prefix: prefix)

    work_orders_with_asset =
      Enum.map(work_orders, fn work_order ->
        asset =
          case work_order.asset_type do
            "E" -> AssetConfig.get_equipment!(work_order.asset_id, prefix)
            "L" -> AssetConfig.get_location!(work_order.asset_id, prefix)
            _ ->
              get_asset_from_workorder_template(work_order, prefix)

          end
          Map.put_new(work_order, :asset, asset)
      end)

    result =


      Enum.map(work_orders_with_asset, fn wo ->
        asset_type = get_asset_type_from_workorder_template(wo, prefix)
        {asset_name, asset_code} =
          case asset_type do
            "E" ->
              {wo.asset.name, wo.asset.equipment_code}

            "L" ->
              {wo.asset.name, wo.asset.location_code}
          end

        name =
          if wo.first_name == nil, do: wo.username, else: wo.first_name

        manhours_consumed =
          cond do
            wo.start_time == nil and wo.completed_time == nil ->
              0

            wo.completed_time == nil ->
              Time.diff(get_site_time(wo.site_id, prefix), wo.start_time)

            true ->
              Time.diff(wo.completed_time, wo.start_time)
          end

        %{
          asset_name: asset_name,
          asset_code: asset_code,
          type: wo.type,
          status: wo.status,
          assigned_to: name,
          manhours_consumed: manhours_consumed * 3600
        }
      end)

    report_headers = ["Asset Name", "Asset Code", "Type", "Status", "Assigned To", "Manhours Consumed"]

    case query_params["type"] do
      "pdf" ->
        convert_to_pdf("Work Order Report", result, report_headers, "WO")

      "csv" ->
        csv_for_workorder_report(report_headers, result)

      _ ->
        result
    end
  end

  def inventory_report(prefix, query_params) do

    query_params = rectify_query_params(query_params)

    main_query =
      from it in InventoryTransaction,
            join: i in Item, on: i.id == it.item_id,
            join: st in InventoryStock, on: st.item_id == i.id,
            join: u in UOM, on: u.id == it.uom_id,
            join: il in InventoryLocation, on: st.inventory_location_id == il.id,
            join: s in Supplier, on: s.id == it.supplier_id,
            select:
              %{
                item_name: i.name,
                item_type: i.type,
                asset_category_ids: i.asset_categories_ids,
                quantity_held: st.quantity,
                transaction_quantity: it.quantity,
                reorder_level: i.reorder_quantity,
                uom: u.symbol,
                store_name: il.name,
                aisle: i.aisle,
                bin: i.bin,
                row: i.row,
                cost: it.cost,
                supplier: s.name,
                transaction_type: it.transaction_type,
                inserted_at: it.inserted_at }

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"transaction_type", transaction_type}, main_query ->
          from q in main_query, where: q.transaction_type == ^transaction_type

        {"asset_category_id", asset_category_id}, main_query ->
          from q in main_query, where: ^asset_category_id in q.asset_categories_ids

        _, main_query ->
          main_query
      end)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    naive_from_date = convert_date_to_naive_date_time(from_date)
    naive_to_date = convert_date_to_naive_date_time(to_date)

    IO.inspect(naive_from_date > naive_to_date)

    # query_with_dates = from dq in dynamic_query, where: dq.inserted_at >= ^naive_from_date and dq.inserted_at <= ^naive_to_date

    inventory_transactions = Repo.all(dynamic_query, prefix: prefix)


    Enum.map(inventory_transactions, fn it ->

      asset_category =
        Enum.map(it.asset_category_ids, fn id ->
          Inconn2Service.AssetConfig.get_asset_category!(id, prefix).name
        end) |> Enum.join(",")

      IO.inspect(it.inserted_at >= naive_from_date)

      %{
        item_name: it.item_name,
        item_type: it.item_type,
        asset_category: asset_category,
        quantity_held: it.quantity_held,
        reorder_level: it.reorder_level,
        uom: it.uom,
        store_name: it.store_name,
        aisle_bin_row: it.aisle <> "-" <> it.bin <> "-" <> it.row,
        supplier: it.supplier
      }
    end)
  end

  def work_request_report(prefix, query_params) do
    query_params = rectify_query_params(query_params)

    main_query = from wo in WorkRequest

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"status", status}, main_query ->
          from q in main_query, where: q.status == ^status

        {"workrequest_category_id", workrequest_category_id}, main_query ->
          from q in main_query, where: q.workrequest_category_id == ^workrequest_category_id

        {"assigned_user_id", assigned_user_id}, main_query ->
          from q in main_query, where: q.assigned_user_id == ^assigned_user_id

        _, main_query ->
          main_query

      end)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    naive_from_date = convert_date_to_naive_date_time(from_date)
    naive_to_date = convert_date_to_naive_date_time(to_date)

    query_with_dates = from dq in dynamic_query, where: dq.raised_date_time >= ^naive_from_date and dq.raised_date_time <= ^naive_to_date

    work_requests =
      Repo.all(query_with_dates, prefix: prefix)
      |> Repo.preload([:workrequest_category, :workrequest_subcategory, :location, :site, requested_user: :employee, assigned_user: :employee])

    work_requests_with_asset =
      Enum.map(work_requests, fn work_request ->
        asset =
          case work_request.asset_type do
            "E" -> AssetConfig.get_equipment(work_request.asset_id, prefix)
            "L" -> AssetConfig.get_location(work_request.asset_id, prefix)
            _ -> nil
          end
          Map.put_new(work_request, :asset, asset)
      end)

    result =
      Enum.map(work_requests_with_asset, fn wr ->

        asset_name =
          if wr.asset != nil do
            wr.asset.name
          else
            nil
          end

        asset_category =
          if wr.asset != nil do
            IO.inspect(wr.asset)
            AssetConfig.get_asset_category!(wr.asset.asset_category_id, prefix).name
          else
            nil
          end

        raised_by =
          cond do
            wr.requested_user != nil && wr.requested_user.employee != nil ->
              wr.requested_user.employee.first_name <> " " <> wr.requested_user.employee.last_name

            wr.requested_user != nil ->
              wr.requested_user.username

            true ->
              nil
          end


          assigned_to =
            cond do
              wr.assigned_user != nil && wr.assigned_user.employee != nil ->
                wr.assigned_user.employee.first_name <> " " <> wr.assigned_user.employee.last_name

              wr.assigned_user != nil ->
                wr.assigned_user.username

              true ->
                nil
            end



        %{
          asset_name: asset_name,
          asset_category: asset_category,
          raised_by: raised_by,
          assigned_to: assigned_to,
          response_tat: "Yes",
          resolution_tat: "Yes",
          status: match_work_request_status(wr.status),
          time_taken_to_close: 200
        }
      end)

    report_headers = ["Asset Name", "Asset Category", "Raised By", "Assigned To", "Response TAT", "Resolution TAT", "Status", "Time Taken to Complete"]

    case query_params["type"] do
      "pdf" ->
        convert_to_pdf("Work Request Report", result, report_headers, "WR")

      "csv" ->
        csv_for_workrequest_report(report_headers, result)

      _ ->
        result
    end
  end


  def asset_status_report(prefix, query_params) do
    query_params = rectify_query_params(query_params)
    equipments_data = get_equipment_details(prefix, query_params)

    report_headers = ["Asset Name", "Asset Code", "Asset Category", "Status", "Criticality", "Up Time", "Utilized Time", "PPM Completion Percentage"]

    case query_params["type"] do
      "pdf" ->
        convert_to_pdf("Asset Status Report", equipments_data, report_headers, "AST")

      "csv" ->
        csv_for_asset_status_report(report_headers, equipments_data)

      _ ->
        equipments_data
    end

  end

  defp get_equipment_details(prefix, query_params) do
    main_query = from e in Equipment

    dynamic_query =
      Enum.reduce(query_params, main_query, fn
        {"site_id", site_id}, main_query ->
          from q in main_query, where: q.site_id == ^site_id

        {"location_id", location_id}, main_query ->
          from q in main_query, where: q.location_id == ^location_id

        {"status", status}, main_query ->
          from q in main_query, where: q.status == ^status

        {"asset_category_id", asset_category_id}, main_query ->
          from q in main_query, where: q.asset_category_id == ^asset_category_id

        _ , main_query ->
          main_query
      end)


    equipments = Repo.all(dynamic_query, prefix: prefix)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    naive_from_date = convert_date_to_naive_date_time(from_date)
    naive_to_date = convert_date_to_naive_date_time(to_date)


    Enum.map(equipments, fn e ->
      asset_status_tracks =
        from(ast in AssetStatusTrack, where: ast.asset_id == ^e.id and ast.asset_type == ^"E" and ast.changed_date_time >= ^naive_from_date and ast.changed_date_time <= ^naive_to_date)
        |> Repo.all(prefix: prefix)

      up_time =
        Enum.filter(asset_status_tracks, fn ast -> ast.status in ["ON", "OFF"] end)
        |> Enum.map(fn ast -> ast.hours end)
        |> Enum.sum()

      utilized_time =
        Enum.filter(asset_status_tracks, fn ast -> ast.status in ["ON"] end)
        |> Enum.map(fn ast -> ast.hours end)
        |> Enum.sum()

      ppm_work_orders =
        (from wo in WorkOrder, where: wo.asset_id == ^e.id and wo.asset_type == ^"E" and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date)
        |> Repo.all(prefix: prefix)

      completed_ppm = Enum.filter(ppm_work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()

      completion_percentage =
        if length(ppm_work_orders) != 0 do
          div(completed_ppm,length(ppm_work_orders))
        else
          0
        end

      %{
        asset_name: e.name,
        asset_code: e.equipment_code,
        asset_category: AssetConfig.get_asset_category!(e.asset_category_id, prefix).name,
        status: e.status,
        criticality: e.criticality,
        up_time: up_time,
        utilized_time: utilized_time,
        ppm_completion_percentage: completion_percentage
      }
    end)
  end

  defp get_asset_from_workorder_template(work_order, prefix) do
    workorder_template = Workorder.get_workorder_template!(work_order.workorder_template_id, prefix)
    case workorder_template.asset_type do
      "L" ->
        AssetConfig.get_location(work_order.asset_id, prefix)

      "E" ->
        AssetConfig.get_equipment(work_order.asset_id, prefix)
    end
  end

  defp get_asset_type_from_workorder_template(work_order, prefix) do
    workorder_template = Workorder.get_workorder_template!(work_order.workorder_template_id, prefix)
    workorder_template.asset_type
  end

  defp get_site_time(site_id, prefix) do
    site = Repo.get!(Site, site_id, prefix: prefix)
    date_time = DateTime.now!(site.time_zone)
    result = NaiveDateTime.new!(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.minute, date_time.second)
    NaiveDateTime.to_time(result)
  end

  # def asset_status_reports(query_params, prefix) do
  #   {asset_type, asset_ids} = get_assets_by_asset_category_id(query_params["asset_category_id"], prefix)
  # end

  def get_assets_by_asset_category_id(asset_category_id, prefix) do
    asset_category = AssetConfig.get_asset_category!(asset_category_id, prefix)
    assets =
      case asset_category.asset_type do
        "L" ->
          Location |> where([asset_category_id: ^asset_category_id]) |> Repo.all(prefix: prefix)

        "E" ->
          Equipment |> where([asset_category_id: ^asset_category_id]) |> Repo.all(prefix: prefix)
      end
    {asset_category.asset_type, Enum.map(assets, fn a -> a.id end)}
  end

  defp rectify_query_params(query_params) do
    Enum.filter(query_params, fn {key, value} ->
      if value != "null", do: {key, value}
    end) |> Enum.into(%{})
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

  defp convert_date_to_naive_date_time(date) do
    NaiveDateTime.new!(date, Time.new!(0, 0, 0))
  end


  defp convert_to_pdf(report_title, data, report_headers, report_for) do
    create_report_structure(report_title, data, report_headers, report_for)
  end

  def create_report_structure(report_title, data, report_headers, report_for) do
    string =
      Sneeze.render(
        [
          :div,
          [
            :h1,
            %{
              style: style(%{"text-align" => "center"})
            },
            "#{report_title}"
          ],
          [
            :table,
            %{style: style(%{"width" => "100%", "border" => "1px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
            create_report_headers(report_headers),
            create_table_body(data, report_for)
          ]
        ]
      )
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end


  defp create_report_headers(report_headers) do
    [
      :tr,
      %{
        style: style(%{"text-align" => "center"})
      },
      Enum.map(report_headers, fn h ->
        [
          :th,
          %{style: style(%{"text-align" => "center", "font-weight" => "bold", "border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          "#{h}"
        ]
      end)
    ]
  end

  defp create_table_body(report_body_json, "AST") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_code
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_category
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.status
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.criticality
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.up_time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.utilized_time
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.ppm_completion_percentage
        ],
      ]
    end)
  end

  defp create_table_body(report_body_json, "WR") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_category
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.raised_by
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.assigned_to
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.response_tat
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.resolution_tat
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.status
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.time_taken_to_close
        ],
      ]
    end)
  end

  defp create_table_body(report_body_json, "WO") do
    Enum.map(report_body_json, fn rbj ->
      [
        :tr,
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_name
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.asset_code
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          match_work_order_type(rbj.type)
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          match_work_order_status(rbj.status)
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.assigned_to
        ],
        [
          :td,
          %{style: style(%{"border" => "1 px solid black", "border-collapse" => "collapse", "padding" => "10px"})},
          rbj.manhours_consumed
        ],
      ]
    end)
  end

  defp csv_for_workorder_report(report_headers, data) do
    body =
      Enum.map(data, fn d ->
        [d.asset_name, d.asset_code, match_work_order_type(d.type), match_work_order_status(d.status), d.assigned_to, d.manhours_consumed]
      end)

    [report_headers] ++ body
  end

  defp csv_for_workrequest_report(report_headers, data) do
    body =
      Enum.map(data, fn d ->
        [d.asset_name, d.asset_category, d.raised_by, d.assigned_to, d.response_tat, d.resolution_tat, d.status, d.time_taken_to_close]
      end)

    [report_headers] ++ body
  end

  defp csv_for_asset_status_report(report_headers, data) do
    body =
      Enum.map(data, fn d ->
        [d.asset_name, d.asset_code, d.asset_category, d.status, d.criticality, d.up_time, d.utilized_time, d.ppm_completion_percentage]
      end)

    [report_headers] ++ body
  end

  defp match_work_order_type(type) do
    case type do
      "BRK" -> "Breakdown"
      "PPM" -> "Preventive Maintainance"
      "TKT" -> "Through a Ticket"
      "PRV" -> "Preventive Maintainance"
    end
  end

  defp match_work_order_status(status) do
    case status do
      "cr" -> "Created"
      "as" -> "Assigned"
      "ip" -> "Inprogress"
      "incp" -> "Incomplete"
      "cp" -> "Complete"
      "cn" -> "Canceled"
      "ht" -> "Hold"
      _ -> status
    end
  end

  defp match_work_request_status(status) do
    case status do
      "RS" -> "Raised"
      "AP" -> "Approved"
      "AS" -> "Assigned"
      "RJ" -> "Rejected"
      "CL" -> "Closed"
      "CS" -> "Cancelled"
      "RO" -> "Reopened"
    end
  end



  IO.inspect("---------------------------------------------------------------------------------")

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

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} ->
      "#{key}: #{value}"
    end)
    |> Enum.join(";")
  end

  def generate_qr_code_for_locations(site_id, prefix) do
    locations_qr = Inconn2Service.AssetConfig.list_locations_qr(site_id, prefix)
    "inc_" <> sub_domain = prefix

    body =
      Sneeze.render([
        :div,
        %{
          style: style(%{
            "display" => "flex",
            "flex-direction" => "column",
            "align-items" => "flex-start"
          })
        },
        render_img_qr(locations_qr, sub_domain),
      ])

    # img_render_string = render_img_qr(locations_qr, sub_domain)

    IO.inspect(body)
    # IO.inspect(img_render_string)
    string = Sneeze.render([
      [:__@raw_html, body]])

    # {:ok, filename} = PdfGenerator.generate(html_bootstrap_header() <> ~s(<div class="row">) <> body <> "</div>" <> html_bootstrap_footer(), page_size: "A4")
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def generate_qr_code_for_equipments(site_id, prefix) do
    equipments_qr = Inconn2Service.AssetConfig.list_equipments_qr(site_id, prefix)
    "inc_" <> sub_domain = prefix

    body =
      Sneeze.render([
        :div,
        %{
          style: style(%{
            "display" => "flex",
            "flex-direction" => "column",
            "align-items" => "flex-start"
          })
        },
        render_img_qr(equipments_qr, sub_domain),
      ])

    # img_render_string = render_img_qr(locations_qr, sub_domain)

    IO.inspect(body)
    # IO.inspect(img_render_string)
    string = Sneeze.render([
      [:__@raw_html, body]])

    # {:ok, filename} = PdfGenerator.generate(html_bootstrap_header() <> ~s(<div class="row">) <> body <> "</div>" <> html_bootstrap_footer(), page_size: "A4")
    {:ok, filename} = PdfGenerator.generate(string, page_size: "A4")
    {:ok, pdf_content} = File.read(filename)
    pdf_content
  end

  def render_img_qr(qr_list, sub_domain) do
    Enum.map(qr_list, fn x ->

      # IO.inspect("http://#{sub_domain}.inconn.io:4000#{x.asset_qr_url}")
      [
        :div,
        %{
          style: style(%{"display" => "inline-block", "padding" => "10px", "text-align" => "center"})
        },
        [
          :img,
          %{
            src: "http://#{sub_domain}.inconn.io:4000#{x.asset_qr_url}",
            style: style(%{
              "height" => "250px",
              "width" => "250px"
            })
          },
        ],
        [:h3, %{style: style(%{"text-align" => "center", "width" => "250px"})}, "#{x.asset_name}"]
      ]

    end)
  end

  def html_bootstrap_header do
  starting_tags = "<html><head>"
  bootstrap_link = ~s(<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">)
  bootstrap_script= ~s(<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>)
  starting_finish_tags = "</head>"

  starting_tags <> bootstrap_link <> bootstrap_script <> starting_finish_tags <> "<body>"
  end

  def html_bootstrap_footer, do: "</body></html>"

  def csg_workorder_report(prefix) do
    date = Date.utc_today |> Date.add(-1)

    header = ~s(<p style="float:left">Site:CACIPL-Continental South Gate</p><p style="float:right">Date: #{Date.utc_today}</p>)

    heading = ~s(<table border=1px solid black style="border-collapse: collapse" width="100%"><th></th><th></th><th>7:00</th><th>9:00</th><th>11:00</th><th>13:00</th><th>15:00</th><th>17:00</th>)

    work_order_groups = WorkOrder |> where(scheduled_date: ^date) |> Repo.all(prefix: prefix) |> Enum.group_by(&(&1.asset_id))
    IO.inspect(work_order_groups)

    data =
      Enum.map(work_order_groups, fn {key, work_orders} ->
        asset = Repo.get(Location, key, prefix: prefix)
        work_order_template = Repo.get(WorkorderTemplate, List.first(work_orders).workorder_template_id, prefix: prefix)
        complete_status_string =
          Enum.map(work_orders, fn w ->
            case w.status do
              "cp" -> "Y"
              _ -> "N"
            end
          end) |> Enum.join("<td>")
        "<td>" <> work_order_template.name <> " - " <> asset.name <> "</td><td>" <> complete_status_string <> "</tr>"
      end) |> put_sr_no() |> Enum.join()

      remarks_data =
        Enum.map(work_order_groups, fn {_key, work_orders} ->
          # asset = Repo.get(Location, key)
          work_order_template = Repo.get(WorkorderTemplate, List.first(work_orders).workorder_template_id, prefix: prefix)
          complete_status_string =
            Enum.map(work_orders, fn w ->
              tasks = WorkorderTask |> where([work_order_id: ^w.id]) |> Repo.all(prefix: prefix)
              Enum.map(tasks, fn t -> t.remarks end) |> Enum.filter(fn x -> x != "" end) |> Enum.join(",")
            end) |> Enum.join("<td>")
          "<td>" <> work_order_template.name <> "</td><td>" <> complete_status_string <> "</tr>"
        end) |> put_sr_no() |> Enum.join()

    IO.inspect(data)


    {:ok, filename} = PdfGenerator.generate(report_heading("Work order completion reports") <> header <> heading <> data <>  ~s(</table>) <> ~s(<div style="page-break-before: always">)<> report_heading("Work order remarks generated") <> heading <> remarks_data <> "</table> <br/>" <> ~s(<p style="float:right">Powered By INCONN</p>), page_size: "A4", shell_params: ["--orientation", "landscape"])
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


  # def inventory_report(prefix) do
  #   query = from it in InventoryTransaction,
  #           join: i in Item, on: i.id == it.item_id,
  #           join: st in InventoryStock, on: st.item_id == i.id,
  #           join: u in UOM, on: u.id == it.uom_id,
  #           join: il in InventoryLocation, on: st.inventory_location_id == il.id,
  #           join: s in Supplier, on: s.id == it.supplier_id,
  #           select: { i.name, i.type, i.asset_categories_ids, st.quantity, it.quantity, i.reorder_quantity, u.symbol, il.name, i.aisle, i.bin, i.row, it.cost, s.name, it.transaction_type }

  #   inventory_items = Repo.all(query, prefix: prefix)

  #   Enum.map(inventory_items, fn inventory_item ->
  #     %{
  #       item_name: elem(inventory_item, 0),
  #       item_type: elem(inventory_item, 1),
  #       asset_categories: elem(inventory_item, 2),
  #       quantity_held: elem(inventory_item, 3),
  #       transaction_quantity: elem(inventory_item, 4),
  #       reorder_level: elem(inventory_item, 5),
  #       uom: elem(inventory_item, 6),
  #       store_name: elem(inventory_item, 7),
  #       aisle: elem(inventory_item, 8),
  #       bin: elem(inventory_item, 9),
  #       row: elem(inventory_item, 10),
  #       cost: elem(inventory_item, 11),
  #       supplier: elem(inventory_item, 12),
  #       transaction_type: elem(inventory_item, 13)
  #     }
  #   end)
  # end

  def report_heading(heading) do
    "</b><center><h1>#{heading}</h1></center>"
  end

  def get_name_from_user(user) do
    case user.employee do
      nil -> user.username
      _ -> user.employee.first_name
    end
  end
end

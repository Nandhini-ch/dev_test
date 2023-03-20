defmodule Inconn2ServiceWeb.ReferenceUploadController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceDataUploader
  action_fallback Inconn2ServiceWeb.FallbackController

  def upload_zones(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_zones(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_sites(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_sites(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_asset_categories(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_asset_categories(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_locations(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_locations(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_equipments(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_equipments(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_check_types(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_check_types(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_checks(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_checks(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_check_lists(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_check_lists(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_master_task_types(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_master_task_types(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_tasks(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_tasks(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_task_lists(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_task_lists(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_workorder_templates(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_workorder_templates(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_employees(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_employees(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_inventory_items(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_inventory_items(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_inventory_suppliers(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_inventory_suppliers(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_unit_of_measurements(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_unit_of_measurements(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_uom_categories(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_uom_categories(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_parties(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_parties(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_contracts(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_contracts(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_scopes(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_scopes(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_workorder_schedules(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_workorder_schedules(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_users(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_users(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_org_units(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_org_units(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_shifts(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_shifts(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_bankholidays(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_bankholidays(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_employee_rosters(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_employee_rosters(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_uoms(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_uoms(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_items(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_items(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  # def upload_supplier_items(conn, params) do
  #   file = params["csv_file"]
  #   data = ReferenceDataUploader.upload_supplier_items(file, conn.assigns.sub_domain_prefix)

  #   render_response_json(conn, data)
  # end

  def render_response_json(conn, data) do
    case data do
      {:error, error_data} ->
        if error_data == ["Invalid Header Fields"] do
          {:error, "Invalid Header Fields"}
        else
          render(conn, "failure.json", failed_data: error_data)
        end

      {:error_list, error_data} ->
        data =
          error_data
          |> CSV.encode()
          |> Enum.to_list()
          |> to_string

        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"locations.csv\"")
        |> send_resp(201, data)

      _ ->
        render(conn, "success.json", %{})
    end
  end
end

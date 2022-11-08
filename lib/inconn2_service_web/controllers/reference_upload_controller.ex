defmodule Inconn2ServiceWeb.ReferenceUploadController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceDataUploader
  action_fallback Inconn2ServiceWeb.FallbackController

  def upload_locations(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_locations(file, conn.assigns.sub_domain_prefix)

    case data do
      {:error, error_data} ->
        if error_data == ["Invalid Header Fields"] do
          render(conn, "invalid.json", %{})
        else
          render(conn, "failure.json", failed_data: error_data)
        end

      _ ->
        render(conn, "success.json", %{})
    end
  end

  def upload_asset_categories(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_asset_categories(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_task_lists(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_task_lists(file, conn.assigns.sub_domain_prefix)

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

  def upload_workorder_templates(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_workorder_templates(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_workorder_schedules(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_workorder_schedules(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_sites(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_sites(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_employees(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_employees(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_tasks(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_tasks(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_master_task_types(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_master_task_types(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

  def upload_check_types(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_check_types(file, conn.assigns.sub_domain_prefix)

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

  def upload_equipments(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_equipments(file, conn.assigns.sub_domain_prefix)

    case data do
      {:error, error_data} ->
        if error_data == ["Invalid Header Fields"] do
          render(conn, "invalid.json", %{})
        else
          render(conn, "failure.json", failed_data: error_data)
        end

      _ ->
        render(conn, "success.json", %{})
    end
  end

  def render_response_json(conn, data) do
    case data do
      {:error, error_data} ->
        if error_data == ["Invalid Header Fields"] do
          render(conn, "invalid.json", %{})
        else
          render(conn, "failure.json", failed_data: error_data)
        end

      _ ->
        render(conn, "success.json", %{})
    end
  end

end

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

  def upload_sites(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_sites(file, conn.assigns.sub_domain_prefix)

    render_response_json(conn, data)
  end

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

defmodule Inconn2ServiceWeb.ReferenceDownloadController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceDataDownloader
  action_fallback Inconn2ServiceWeb.FallbackController

  def download_locations(conn, _params) do
    data =
      ReferenceDataDownloader.download_locations(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"locations.csv\"")
    |> send_resp(200, data)
  end

  def download_asset_categories(conn, _params) do
    data =
      ReferenceDataDownloader.download_asset_categories(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"asset_categories.csv\"")
    |> send_resp(200, data)
  end

  def download_equipments(conn, _params) do
    data =
      ReferenceDataDownloader.download_equipments(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string


    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"equipments.csv\"")
    |> send_resp(200, data)
  end

  def download_sites(conn, _params) do
    data =
      ReferenceDataDownloader.download_sites(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"sites.csv\"")
    |> send_resp(200, data)
  end

  def download_workorder_templates(conn, _params) do
    data =
      ReferenceDataDownloader.download_work_order_templates(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"work_order_template.csv\"")
    |> send_resp(200, data)
  end

  def download_workorder_schedules(conn, _params) do
    data =
      ReferenceDataDownloader.download_workorder_schedules(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"workorder_schedules.csv\"")
    |> send_resp(200, data)
  end

  def download_tasks(conn, _params) do
    data =
      ReferenceDataDownloader.download_tasks(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"tasks.csv\"")
    |> send_resp(200, data)
  end

  def download_task_lists(conn, _params) do
    data =
      ReferenceDataDownloader.download_task_lists(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"task_lists.csv\"")
    |> send_resp(200, data)
  end

  def download_check_lists(conn, _params) do
    data =
      ReferenceDataDownloader.download_check_lists(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"check_lists.csv\"")
    |> send_resp(200, data)
  end

  def download_checks(conn, _params) do
    data =
      ReferenceDataDownloader.download_checks(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"checks.csv\"")
    |> send_resp(200, data)
  end

end

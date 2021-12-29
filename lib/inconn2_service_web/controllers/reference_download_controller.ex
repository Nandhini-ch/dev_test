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

  def download_employees(conn, _params) do
    data =
      ReferenceDataDownloader.download_employees(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"employees.csv\"")
    |> send_resp(200, data)
  end

  def download_users(conn, _params) do
    data =
      ReferenceDataDownloader.download_users(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"users.csv\"")
    |> send_resp(200, data)
  end

  def download_employee_rosters(conn, _params) do
    data =
      ReferenceDataDownloader.download_employee_rosters(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"employee_roster.csv\"")
    |> send_resp(200, data)
  end

  def download_org_units(conn, _params) do
    data =
      ReferenceDataDownloader.download_org_units(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"org_units.csv\"")
    |> send_resp(200, data)
  end

  def download_shifts(conn, _params) do
    data =
      ReferenceDataDownloader.download_shifts(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"shifts.csv\"")
    |> send_resp(200, data)
  end

  def download_bankholidays(conn, _params) do
    data =
      ReferenceDataDownloader.download_bankholidays(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"bankholidays.csv\"")
    |> send_resp(200, data)
  end

  def download_inventory_locations(conn, _params) do
    data =
      ReferenceDataDownloader.download_inventory_locations(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"inventory_locations.csv\"")
    |> send_resp(200, data)
  end

  def download_inventory_stocks(conn, _params) do
    data =
      ReferenceDataDownloader.download_inventory_stocks(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"inventory_stocks.csv\"")
    |> send_resp(200, data)
  end

  def download_items(conn, _params) do
    data =
      ReferenceDataDownloader.download_items(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"items.csv\"")
    |> send_resp(200, data)
  end

  def download_suppliers(conn, _params) do
    data =
      ReferenceDataDownloader.download_suppliers(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"suppliers.csv\"")
    |> send_resp(200, data)
  end

  def download_supplier_items(conn, _params) do
    data =
      ReferenceDataDownloader.download_supplier_items(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"suplier_items.csv\"")
    |> send_resp(200, data)
  end

  def download_uoms(conn, _params) do
    data =
      ReferenceDataDownloader.download_uoms(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"uoms.csv\"")
    |> send_resp(200, data)
  end

  def download_uom_conversions(conn, _params) do
    data =
      ReferenceDataDownloader.download_uom_conversions(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"uom_conversions.csv\"")
    |> send_resp(200, data)
  end



  def download_roles(conn, _params) do
    data =
      ReferenceDataDownloader.download_roles(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"roles.csv\"")
    |> send_resp(200, data)
  end

  def download_asset_qrs(conn, _params) do
    data =
      ReferenceDataDownloader.download_asset_qrs(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"roles.csv\"")
    |> send_resp(200, data)
  end

end

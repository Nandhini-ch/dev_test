defmodule Inconn2ServiceWeb.EmployeeRosterController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.EmployeeRoster

  action_fallback Inconn2ServiceWeb.FallbackController

  # def index(conn, _params) do
  #   employee_rosters = Assignment.list_employee_rosters(conn.query_params, conn.assigns.sub_domain_prefix)
  #   render(conn, "index.json", employee_rosters: employee_rosters)
  # end

  def index(conn, _params) do
    query_params = Map.keys(conn.query_params)
    case query_params do
       [] ->
              employee_rosters = Assignment.list_employee_rosters(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
              render(conn, "index.json", employee_rosters: employee_rosters)

       ["date", "shift_id"] ->
              employee_rosters = Assignment.list_employee_roster_for_shift_and_date(conn.query_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
              render(conn, "index.json", employee_rosters: employee_rosters)

       ["date", "site_id"] ->
              employee_rosters = Assignment.list_employee_roster_for_site_and_date(conn.query_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
              render(conn, "index.json", employee_rosters: employee_rosters)

       ["from_date", "site_id", "to_date"] ->
              employees = Assignment.list_employees_for_date_range(conn.query_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
              render(conn, "employee_index.json", employees: employees)
    end
  end

  def index_sites_for_attendance(conn, _params) do
    sites = Assignment.list_sites_from_roster(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "site_index.json", sites: sites)
  end

  def employees(conn, _params) do
    employees = Assignment.list_employee_for_attendance(conn.query_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "employee_index.json", employees: employees)
  end

  def employees_for_manual_attendance(conn, _) do
    employees = Assignment.list_manual_employee_for_attendance(conn.query_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "employee_index.json", employees: employees)
  end

  def create(conn, %{"employee_roster" => employee_roster_params}) do
    with {:ok, %EmployeeRoster{} = employee_roster} <- Assignment.create_employee_roster(employee_roster_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.employee_roster_path(conn, :show, employee_roster))
      |> render("show.json", employee_roster: employee_roster)
    end
  end

  def show(conn, %{"id" => id}) do
    employee_roster = Assignment.get_employee_roster!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", employee_roster: employee_roster)
  end

  def update(conn, %{"id" => id, "employee_roster" => employee_roster_params}) do
    employee_roster = Assignment.get_employee_roster!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EmployeeRoster{} = employee_roster} <- Assignment.update_employee_roster(employee_roster, employee_roster_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", employee_roster: employee_roster)
    end
  end

  def delete(conn, %{"id" => id}) do
    employee_roster = Assignment.get_employee_roster!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EmployeeRoster{}} <- Assignment.delete_employee_roster(employee_roster, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_employee_rosters(conn, %{"id" => id}) do
    employee_roster = Assignment.get_employee_roster!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EmployeeRoster{} = employee_roster} <- Assignment.update_employee_roster(employee_roster, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", employee_roster: employee_roster)
    end
  end

  def deactivate_employee_rosters(conn, %{"id" => id}) do
    employee_roster = Assignment.get_employee_roster!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %EmployeeRoster{} = employee_roster} <- Assignment.update_employee_roster(employee_roster, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", employee_roster: employee_roster)
    end
  end
end

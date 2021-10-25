defmodule Inconn2ServiceWeb.EmployeeRosterController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.EmployeeRoster

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    employee_rosters = Assignment.list_employee_rosters(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", employee_rosters: employee_rosters)
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

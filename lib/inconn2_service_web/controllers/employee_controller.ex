defmodule Inconn2ServiceWeb.EmployeeController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Employee

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"party_id" => party_id}) do
    employees = Staff.list_employees(party_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", employees: employees)
  end

  def create(conn, %{"employee" => employee_params}) do
    with {:ok, %Employee{} = employee} <- Staff.create_employee(employee_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.employee_path(conn, :show, employee))
      |> render("show.json", employee: employee)
    end
  end

  def show(conn, %{"id" => id}) do
    employee = Staff.get_employee!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", employee: employee)
  end

  def update(conn, %{"id" => id, "employee" => employee_params}) do
    employee = Staff.get_employee!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Employee{} = employee} <-
           Staff.update_employee(employee, employee_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", employee: employee)
    end
  end

  def delete(conn, %{"id" => id}) do
    employee = Staff.get_employee!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Employee{}} <- Staff.delete_employee(employee, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_employee(conn, %{"id" => id}) do
    employee = Staff.get_employee!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Employee{} = employee} <-
           Staff.update_active_status_for_employee(employee, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", employee: employee)
    end
  end

  def deactivate_employee(conn, %{"id" => id}) do
    employee = Staff.get_employee!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Employee{} = employee} <-
           Staff.update_active_status_for_employee(employee, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", employee: employee)
    end
  end
end

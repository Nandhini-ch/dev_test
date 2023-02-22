defmodule Inconn2ServiceWeb.EmployeeController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Employee

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, params) do
    employees = Staff.list_employees(params, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", employees: employees)
  end

  def index_of_party(conn, _params) do
    employees = Staff.verify_the_licensee_in_party(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index_without_preloads.json", employees: employees)
  end

  def reportees_for_logged_in_user(conn, _params) do
    employees = Staff.get_reportees_for_logged_in_user(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", employees: employees)
  end

  def reportees_for_employee(conn, %{"employee_id" => employee_id}) do
    employees = Staff.get_reportees_for_employee(employee_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", employees: employees)
  end

  def create(conn, %{"employee" => employee_params}) do
    # employee_params = temporary_patch_for_skills(employee_params)
    #                   |> temporary_fix_for_role_id(employee_params)
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
    # employee_params = temporary_patch_for_skills(employee_params)
    #                     |> temporary_fix_for_role_id()
    with {:ok, %Employee{} = employee} <-
           Staff.update_employee(employee, employee_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", employee: employee)
    end
  end

  def delete(conn, %{"id" => id}) do
    employee = Staff.get_employee!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <- Staff.delete_employee(employee, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  # defp temporary_patch_for_skills(employee_params) do
  #   skills = employee_params["skills"]
  #   if skills != [] or skills != nil do
  #     skills = Enum.map(skills, fn skill -> skill["id"] end)
  #     Map.put(employee_params, "skills", skills)
  #   else
  #     employee_params
  #   end
  # end

  def temporary_fix_for_role_id(employee_params) do
    if Map.has_key?(employee_params, "role") do
      role_id = employee_params["role"]["id"]
      Map.put_new(employee_params, "role_id", role_id)
    else
      employee_params
    end
  end
end

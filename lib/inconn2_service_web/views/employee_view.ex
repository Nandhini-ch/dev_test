defmodule Inconn2ServiceWeb.EmployeeView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.EmployeeView

  def render("index.json", %{employees: employees}) do
    %{data: render_many(employees, EmployeeView, "employee.json")}
  end

  def render("show.json", %{employee: employee}) do
    %{data: render_one(employee, EmployeeView, "employee.json")}
  end

  def render("employee.json", %{employee: employee}) do
    %{
      id: employee.id,
      first_name: employee.first_name,
      last_name: employee.last_name,
      employement_start_date: employee.employement_start_date,
      employment_end_date: employee.employment_end_date,
      designation: employee.designation,
      email: employee.email,
      employee_id: employee.employee_id,
      landline_no: employee.landline_no,
      mobile_no: employee.mobile_no,
      salary: employee.salary,
      reports_to: employee.reports_to,
      has_login_credentials: employee.has_login_credentials,
      org_unit_id: employee.org_unit_id,
      party_id: employee.party_id,
      skills: employee.skills
    }
  end
end

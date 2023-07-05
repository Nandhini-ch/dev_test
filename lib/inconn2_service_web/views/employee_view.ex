defmodule Inconn2ServiceWeb.EmployeeView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.RoleView
  alias Inconn2ServiceWeb.{EmployeeView, OrgUnitView, AssetCategoryView}

  def render("index.json", %{employees: employees}) do
    %{data: render_many(employees, EmployeeView, "employee.json")}
  end

  def render("index_without_preloads.json", %{employees: employees}) do
    %{data: render_many(employees, EmployeeView, "employee_without_org_unit.json")}
  end

  def render("show.json", %{employee: employee}) do
    %{data: render_one(employee, EmployeeView, "employee.json")}
  end

  def render("employee.json", %{employee: employee}) do
    %{
      id: employee.id,
      first_name: employee.first_name,
      last_name: employee.last_name,
      employment_start_date: employee.employment_start_date,
      employment_end_date: employee.employment_end_date,
      designation: render_one(employee.designation, DesignationView, "designation.json"),
      email: employee.email,
      employee_id: employee.employee_id,
      landline_no: employee.landline_no,
      mobile_no: employee.mobile_no,
      salary: employee.salary,
      has_login_credentials: employee.has_login_credentials,
      org_unit: render_one(employee.org_unit, OrgUnitView, "org_unit.json"),
      reports_to: render_one(employee.reports_to_employee, EmployeeView, "employee_without_org_unit.json"),
      party_id: employee.party_id,
      skills: (if is_nil(employee.preloaded_skills), do: [], else: render_many(employee.preloaded_skills, AssetCategoryView, "asset_category.json")),
      designation_id: employee.designation_id,
      role: render_one(employee.role, RoleView, "role_without_permissions.json"),
      # role_id: employee.role_id
    }
  end

  def render("employee_without_org_unit.json", %{employee: employee}) do
    %{
      id: employee.id,
      first_name: employee.first_name,
      last_name: employee.last_name,
      employment_start_date: employee.employment_start_date,
      employment_end_date: employee.employment_end_date,
      email: employee.email,
      employee_id: employee.employee_id,
      designation_id: employee.designation_id,
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

  def render("employee_with_org_unit_only.json", %{employee: employee}) do
    %{
      id: employee.id,
      first_name: employee.first_name,
      last_name: employee.last_name,
      employment_start_date: employee.employment_start_date,
      employment_end_date: employee.employment_end_date,
      # designation: employee.designation,
      designation_id: employee.designation_id,
      email: employee.email,
      employee_id: employee.employee_id,
      landline_no: employee.landline_no,
      mobile_no: employee.mobile_no,
      salary: employee.salary,
      reports_to: employee.reports_to,
      has_login_credentials: employee.has_login_credentials,
      org_unit: render_one(employee.org_unit, OrgUnitView, "org_unit.json"),
      party_id: employee.party_id,
      skills: employee.skills
     }
  end
end

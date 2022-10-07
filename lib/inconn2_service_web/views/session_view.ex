defmodule Inconn2ServiceWeb.SessionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{LicenseeView, RoleView, AssetCategoryView, SiteView, DesignationView}

  def render("success.json", %{token: token}) do
    %{
      result: "success",
      token: token
    }
  end

  # def render("failure.json", %{error: params}) do
  # %{result: params}
  # end

  def render("error.json", %{error: error_message}) do
    %{errors: %{detail: [error_message]}}
  end

  def render("current_user.json", %{current_user: current_user, licensee: licensee, party: party, employee: employee, role: role}) do
    %{
      data: %{
        id: current_user.id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        username: current_user.username,
        party_id: current_user.party_id,
        party_type: party.party_type,
        is_licensee: party.licensee,
        employee_id: current_user.employee_id,
        licensee: render_one(licensee, LicenseeView, "licensee.json"),
        designation: render_one(employee.designation, DesignationView, "designation.json"),
        role: render_one(role, RoleView, "role.json")
      }
    }
  end

  def render("my_profile.json", %{my_profile: my_profile}) do
    %{
      data: %{
        id: my_profile.id,
        name: my_profile.name,
        mobile_no: my_profile.mobile_no,
        role: my_profile.role.name,
        skills: render_many(my_profile.skills, AssetCategoryView, "asset_category.json"),
        sites: render_many(my_profile.sites, SiteView, "site.json")
      }
    }
  end
end

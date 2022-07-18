defmodule Inconn2ServiceWeb.UserView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{UserView, EmployeeView}

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user_mobile.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      mobile_no: user.mobile_no,
      party_id: user.party_id,
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      mobile_no: user.mobile_no,
      party_id: user.party_id,
      role_id: user.role_id,
      employee: render_one(user.employee, EmployeeView, "employee_with_org_unit_only.json")
    }
  end

  def render("user_without_org_unit.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      mobile_no: user.mobile_no,
      party_id: user.party_id,
      role_id: user.role_id,
      employee: render_one(user.employee, EmployeeView, "employee_without_org_unit.json")
    }
  end

  def render("success.json", _user) do
    %{result: "successfully changed the password"}
  end

  def render("error.json", %{error: error_message}) do
    %{errors: %{old_password: [error_message]}}
  end

  def render("not_current_user_error.json", %{error: error_message}) do
    %{errors: %{message: error_message}}
  end
end

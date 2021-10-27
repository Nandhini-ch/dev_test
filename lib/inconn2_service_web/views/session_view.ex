defmodule Inconn2ServiceWeb.SessionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.LicenseeView

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

  def render("current_user.json", %{current_user: current_user, licensee: licensee, party: party, employee: employee, features: features}) do
    %{
      data: %{
        id: current_user.id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        username: current_user.username,
        role_ids: current_user.role_ids,
        party_id: current_user.party_id,
        party_type: party.party_type,
        is_licensee: party.licensee,
        licensee: render_one(licensee, LicenseeView, "licensee.json"),
        features: features
      }
    }
  end
end

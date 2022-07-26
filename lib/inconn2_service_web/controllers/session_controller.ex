defmodule Inconn2ServiceWeb.SessionController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.Account.Auth
  alias Inconn2Service.{AssetConfig, Staff, Account, Assignment}

  def login(conn, %{"username" => username, "password" => password}) do
    prefix = conn.assigns.sub_domain_prefix

    case Auth.authenticate(username, password, prefix) do
      {:ok, user} ->
        # conn = Inconn2Service.Guardian.Plug.sign_in(conn, user)
        conn =
          Inconn2Service.Guardian.Plug.sign_in(conn, %{
            "user" => user,
            "sub_domain_prefix" => prefix
          })

        render(
          conn,
          "success.json",
          %{
            token: Inconn2Service.Guardian.Plug.current_token(conn)
          }
        )

      {:error, reason} ->
        conn
        |> put_status(401)

        render(conn, "error.json", %{error: reason})
    end
  end

  def current_user(conn, _params) do
    current_user = conn.assigns.current_user
    party_id = current_user.party_id
    username = current_user.username
    employee = get_employee_current_user(username, conn.assigns.sub_domain_prefix)
    party = AssetConfig.get_party!(party_id, conn.assigns.sub_domain_prefix)
    sub_domain = String.replace_prefix(conn.assigns.sub_domain_prefix, "inc_", "")
    licensee = Account.get_licensee_by_sub_domain(sub_domain)
    role = Staff.get_role!(current_user.role_id, conn.assigns.sub_domain_prefix)
    render(conn, "current_user.json", current_user: current_user, licensee: licensee, party: party, employee: employee, role: role)
  end

  def my_profile(conn, _params) do
    employee = Staff.get_employee_of_user(conn.assigns.current_user, conn.assigns.sub_domain_prefix)

    my_profile =
    %{
      id: conn.assigns.current_user.id,
      name: get_first_last_name(conn.assigns.current_user, employee),
      mobile_no: conn.assigns.current_user.mobile_no,
      role: Staff.get_role_without_preload(conn.assigns.current_user.role_id, conn.assigns.sub_domain_prefix),
      skills: get_skills_for_employee(employee, conn.assigns.sub_domain_prefix),
      sites: Assignment.list_sites_for_employee(employee, conn.assigns.sub_domain_prefix)
    }
    render(conn, "my_profile.json", my_profile: my_profile)
  end

  defp get_skills_for_employee(nil, _), do: []
  defp get_skills_for_employee(employee, prefix), do: AssetConfig.get_asset_category_by_ids(employee.skills, prefix)

  defp get_first_last_name(_, nil), do: ""
  defp get_first_last_name(user, employee) do
    cond do
      not is_nil(user.first_name) and not is_nil(user.last_name)  ->
        user.first_name <> user.last_name

      true ->
        employee.first_name <> employee.last_name
    end
  end

  defp get_employee_current_user(username, prefix) do
    employee = Staff.get_employee_email!(username, prefix)
    case employee do
      nil -> %{first_name: nil, last_name: nil}
      _ -> employee
    end
  end
end

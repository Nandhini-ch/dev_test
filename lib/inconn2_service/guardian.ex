defmodule Inconn2Service.Guardian do
  use Guardian, otp_app: :inconn2_service
  alias Inconn2Service.Staff
  alias Inconn2Service.Common
  # functions required by Guardian

  def subject_for_token(
        %{"user" => user, "sub_domain_prefix" => sub_domain_prefix},
        _claims
      ) do
    IO.puts("guardian.ex called at this time")
    IO.inspect(user.id)
    IO.inspect(sub_domain_prefix)
    sub = "usr:#{user.id}@#{sub_domain_prefix}"
    {:ok, sub}
  end

  # def subject_for_token(%User{} = user, _claims) do
  #   sub = "user:#{user.id}"
  #   {:ok, sub}
  # end

  def subject_for_token(_, _) do
    {:error, :no_subject}
  end

  # def resource_from_claims(%{"sub" => "user:" <> user_id}) do
  #   IO.inspect(user_id)
  #   resource = Staff.get_user!(user_id, "inc_bata")
  #   {:ok, resource}
  # end

  # def resource_from_claims(%{"sub" => "usr:admin@" <> user_id}) do
  #   user_id = Integer.parse(user_id)
  #   resource = Common.get_admin_user!(user_id)
  #   {:ok, resource}
  # end

  def resource_from_claims(%{"sub" => "usr:" <> user_sub_domain}) do
    IO.inspect(user_sub_domain)
    [user_id | [sub_domain_prefix]] = String.split(user_sub_domain, "@")
    resource = get_user(user_id, sub_domain_prefix)
    # user_id = Integer.parse(user_id)
    # user_id = List.first(Tuple.to_list(user_id))
    # resource = Staff.get_user!(user_id, sub_domain_prefix)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_token}
  end


  defp get_user(user_id, "inc_admin") do
    String.to_integer(user_id) |> Common.get_admin_user!()
  end

  defp get_user(user_id, prefix) do
    String.to_integer(user_id) |> Staff.get_user!(prefix)
  end
end

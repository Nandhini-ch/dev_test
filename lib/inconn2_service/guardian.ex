defmodule Inconn2Service.Guardian do
  use Guardian, otp_app: :inconn2_service
  alias Inconn2Service.Staff.User
  alias Inconn2Service.Staff
  # functions required by Guardian

  def subject_for_token(
        %{"user_id" => user_id, "sub_domain_prefix" => sub_domain_prefix},
        _claims
      ) do
    IO.puts("guardian.ex called at this time")
    IO.inspect(user_id)
    IO.inspect(sub_domain_prefix)
    sub = "user:#{user_id}@#{sub_domain_prefix}"
    {:ok, sub}
  end

  def subject_for_token(%User{} = user, _claims) do
    sub = "user:#{user.id}"
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :no_subject}
  end

  def resource_from_claims(%{"sub" => "user:" <> user_id}) do
    IO.inspect(user_id)
    resource = Staff.get_user!(user_id, "inc_bata")
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_token}
  end
end

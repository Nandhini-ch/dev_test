defmodule Inconn2Service.Confirmation do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Staff
  alias Inconn2Service.Confirmation.ForgotPasswordOtp

  def list_forgot_password_otps(prefix) do
    Repo.all(ForgotPasswordOtp, prefix: prefix)
  end

  def get_forgot_password_otp!(id, prefix), do: Repo.get!(ForgotPasswordOtp, id, prefix: prefix)

  def get_forgot_password_otp_by_user_id(id, prefix) do
    from(fpo in ForgotPasswordOtp, where: fpo.user_id == ^id) |> Repo.one(prefix: prefix)
  end

  def create_forgot_password_otp(attrs \\ %{}, prefix) do
    delete_previous_otp_entrys(attrs["user_id"], prefix)
    %ForgotPasswordOtp{}
    |> ForgotPasswordOtp.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_forgot_password_otp(%ForgotPasswordOtp{} = forgot_password_otp, attrs, prefix) do
    forgot_password_otp
    |> ForgotPasswordOtp.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_forgot_password_otp(%ForgotPasswordOtp{} = forgot_password_otp, prefix) do
    Repo.delete(forgot_password_otp, prefix: prefix)
  end

  def change_forgot_password_otp(%ForgotPasswordOtp{} = forgot_password_otp, attrs \\ %{}) do
    ForgotPasswordOtp.changeset(forgot_password_otp, attrs)
  end

  def confirm_otp(user_id, otp, prefix) do
    otp_entry = get_forgot_password_otp_by_user_id(user_id, prefix)
    cond do
      otp_entry && !otp_entry.validated && to_string(otp_entry.otp) == otp ->
        update_forgot_password_otp(otp_entry, %{"validated" => true}, prefix)
        {:ok, Staff.get_user!(user_id, prefix)}

        otp_entry && !otp_entry.validated ->
          {:error, "Invalid Otp"}

        otp_entry ->
          {:error, "The Otp is not valid, please try the process again"}

        true ->
          {:error, "Please click forgot password again in login screen"}
    end
  end

  defp delete_previous_otp_entrys(user_id, prefix) do
    from(fpo in ForgotPasswordOtp, where: fpo.user_id == ^user_id)
    |> Repo.delete_all(prefix: prefix)
  end
end

defmodule Inconn2Service.ConfirmationTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Confirmation

  describe "forgot_password_otps" do
    alias Inconn2Service.Confirmation.ForgotPasswordOtp

    @valid_attrs %{created_date_time: ~N[2010-04-17 14:00:00], otp: 42, user_id: 42}
    @update_attrs %{created_date_time: ~N[2011-05-18 15:01:01], otp: 43, user_id: 43}
    @invalid_attrs %{created_date_time: nil, otp: nil, user_id: nil}

    def forgot_password_otp_fixture(attrs \\ %{}) do
      {:ok, forgot_password_otp} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Confirmation.create_forgot_password_otp()

      forgot_password_otp
    end

    test "list_forgot_password_otps/0 returns all forgot_password_otps" do
      forgot_password_otp = forgot_password_otp_fixture()
      assert Confirmation.list_forgot_password_otps() == [forgot_password_otp]
    end

    test "get_forgot_password_otp!/1 returns the forgot_password_otp with given id" do
      forgot_password_otp = forgot_password_otp_fixture()
      assert Confirmation.get_forgot_password_otp!(forgot_password_otp.id) == forgot_password_otp
    end

    test "create_forgot_password_otp/1 with valid data creates a forgot_password_otp" do
      assert {:ok, %ForgotPasswordOtp{} = forgot_password_otp} = Confirmation.create_forgot_password_otp(@valid_attrs)
      assert forgot_password_otp.created_date_time == ~N[2010-04-17 14:00:00]
      assert forgot_password_otp.otp == 42
      assert forgot_password_otp.user_id == 42
    end

    test "create_forgot_password_otp/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Confirmation.create_forgot_password_otp(@invalid_attrs)
    end

    test "update_forgot_password_otp/2 with valid data updates the forgot_password_otp" do
      forgot_password_otp = forgot_password_otp_fixture()
      assert {:ok, %ForgotPasswordOtp{} = forgot_password_otp} = Confirmation.update_forgot_password_otp(forgot_password_otp, @update_attrs)
      assert forgot_password_otp.created_date_time == ~N[2011-05-18 15:01:01]
      assert forgot_password_otp.otp == 43
      assert forgot_password_otp.user_id == 43
    end

    test "update_forgot_password_otp/2 with invalid data returns error changeset" do
      forgot_password_otp = forgot_password_otp_fixture()
      assert {:error, %Ecto.Changeset{}} = Confirmation.update_forgot_password_otp(forgot_password_otp, @invalid_attrs)
      assert forgot_password_otp == Confirmation.get_forgot_password_otp!(forgot_password_otp.id)
    end

    test "delete_forgot_password_otp/1 deletes the forgot_password_otp" do
      forgot_password_otp = forgot_password_otp_fixture()
      assert {:ok, %ForgotPasswordOtp{}} = Confirmation.delete_forgot_password_otp(forgot_password_otp)
      assert_raise Ecto.NoResultsError, fn -> Confirmation.get_forgot_password_otp!(forgot_password_otp.id) end
    end

    test "change_forgot_password_otp/1 returns a forgot_password_otp changeset" do
      forgot_password_otp = forgot_password_otp_fixture()
      assert %Ecto.Changeset{} = Confirmation.change_forgot_password_otp(forgot_password_otp)
    end
  end
end

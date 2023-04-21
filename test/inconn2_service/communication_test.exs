defmodule Inconn2Service.CommunicationTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Communication

  describe "send_sms" do
    alias Inconn2Service.Communication.SendSms

    @valid_attrs %{delivery_status: "some delivery_status", error_code: "some error_code", error_message: "some error_message", job_id: "some job_id", message: "some message", message_id: "some message_id", mobile_no: "some mobile_no", template_id: "some template_id", user_id: 42}
    @update_attrs %{delivery_status: "some updated delivery_status", error_code: "some updated error_code", error_message: "some updated error_message", job_id: "some updated job_id", message: "some updated message", message_id: "some updated message_id", mobile_no: "some updated mobile_no", template_id: "some updated template_id", user_id: 43}
    @invalid_attrs %{delivery_status: nil, error_code: nil, error_message: nil, job_id: nil, message: nil, message_id: nil, mobile_no: nil, template_id: nil, user_id: nil}

    def send_sms_fixture(attrs \\ %{}) do
      {:ok, send_sms} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Communication.create_send_sms()

      send_sms
    end

    test "list_send_sms/0 returns all send_sms" do
      send_sms = send_sms_fixture()
      assert Communication.list_send_sms() == [send_sms]
    end

    test "get_send_sms!/1 returns the send_sms with given id" do
      send_sms = send_sms_fixture()
      assert Communication.get_send_sms!(send_sms.id) == send_sms
    end

    test "create_send_sms/1 with valid data creates a send_sms" do
      assert {:ok, %SendSms{} = send_sms} = Communication.create_send_sms(@valid_attrs)
      assert send_sms.delivery_status == "some delivery_status"
      assert send_sms.error_code == "some error_code"
      assert send_sms.error_message == "some error_message"
      assert send_sms.job_id == "some job_id"
      assert send_sms.message == "some message"
      assert send_sms.message_id == "some message_id"
      assert send_sms.mobile_no == "some mobile_no"
      assert send_sms.template_id == "some template_id"
      assert send_sms.user_id == 42
    end

    test "create_send_sms/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communication.create_send_sms(@invalid_attrs)
    end

    test "update_send_sms/2 with valid data updates the send_sms" do
      send_sms = send_sms_fixture()
      assert {:ok, %SendSms{} = send_sms} = Communication.update_send_sms(send_sms, @update_attrs)
      assert send_sms.delivery_status == "some updated delivery_status"
      assert send_sms.error_code == "some updated error_code"
      assert send_sms.error_message == "some updated error_message"
      assert send_sms.job_id == "some updated job_id"
      assert send_sms.message == "some updated message"
      assert send_sms.message_id == "some updated message_id"
      assert send_sms.mobile_no == "some updated mobile_no"
      assert send_sms.template_id == "some updated template_id"
      assert send_sms.user_id == 43
    end

    test "update_send_sms/2 with invalid data returns error changeset" do
      send_sms = send_sms_fixture()
      assert {:error, %Ecto.Changeset{}} = Communication.update_send_sms(send_sms, @invalid_attrs)
      assert send_sms == Communication.get_send_sms!(send_sms.id)
    end

    test "delete_send_sms/1 deletes the send_sms" do
      send_sms = send_sms_fixture()
      assert {:ok, %SendSms{}} = Communication.delete_send_sms(send_sms)
      assert_raise Ecto.NoResultsError, fn -> Communication.get_send_sms!(send_sms.id) end
    end

    test "change_send_sms/1 returns a send_sms changeset" do
      send_sms = send_sms_fixture()
      assert %Ecto.Changeset{} = Communication.change_send_sms(send_sms)
    end
  end

  describe "message_templates" do
    alias Inconn2Service.Communication.MessageTemplates

    @valid_attrs %{message: "some message"}
    @update_attrs %{message: "some updated message"}
    @invalid_attrs %{message: nil}

    def message_templates_fixture(attrs \\ %{}) do
      {:ok, message_templates} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Communication.create_message_templates()

      message_templates
    end

    test "list_message_templates/0 returns all message_templates" do
      message_templates = message_templates_fixture()
      assert Communication.list_message_templates() == [message_templates]
    end

    test "get_message_templates!/1 returns the message_templates with given id" do
      message_templates = message_templates_fixture()
      assert Communication.get_message_templates!(message_templates.id) == message_templates
    end

    test "create_message_templates/1 with valid data creates a message_templates" do
      assert {:ok, %MessageTemplates{} = message_templates} = Communication.create_message_templates(@valid_attrs)
      assert message_templates.message == "some message"
    end

    test "create_message_templates/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communication.create_message_templates(@invalid_attrs)
    end

    test "update_message_templates/2 with valid data updates the message_templates" do
      message_templates = message_templates_fixture()
      assert {:ok, %MessageTemplates{} = message_templates} = Communication.update_message_templates(message_templates, @update_attrs)
      assert message_templates.message == "some updated message"
    end

    test "update_message_templates/2 with invalid data returns error changeset" do
      message_templates = message_templates_fixture()
      assert {:error, %Ecto.Changeset{}} = Communication.update_message_templates(message_templates, @invalid_attrs)
      assert message_templates == Communication.get_message_templates!(message_templates.id)
    end

    test "delete_message_templates/1 deletes the message_templates" do
      message_templates = message_templates_fixture()
      assert {:ok, %MessageTemplates{}} = Communication.delete_message_templates(message_templates)
      assert_raise Ecto.NoResultsError, fn -> Communication.get_message_templates!(message_templates.id) end
    end

    test "change_message_templates/1 returns a message_templates changeset" do
      message_templates = message_templates_fixture()
      assert %Ecto.Changeset{} = Communication.change_message_templates(message_templates)
    end
  end
end

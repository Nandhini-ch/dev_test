defmodule Inconn2Service.Communication do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Communication.SendSms
  alias Inconn2Service.Communication.MessageTemplates
  alias Inconn2Service.Communication.SmsSender

  def list_send_sms(prefix) do
    SendSms
    |> Repo.all(prefix: prefix)
  end

  def get_send_sms!(id, prefix), do: Repo.get!(SendSms, id, prefix: prefix)

  def get_send_sms_by_message_id(nil, _prefix), do: []
  def get_send_sms_by_message_id(message_id, prefix), do: Repo.get_by(SendSms, message_id: message_id, prefix: prefix)


  def create_send_sms(attrs \\ %{}, prefix) do
    %SendSms{}
    |> SendSms.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_send_sms(%SendSms{} = send_sms, attrs, prefix) do
    send_sms
    |> SendSms.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_send_sms(%SendSms{} = send_sms, prefix) do
    Repo.delete(send_sms, prefix: prefix)
  end

  def change_send_sms(%SendSms{} = send_sms, attrs \\ %{}) do
    SendSms.changeset(send_sms, attrs)
  end

  def get_job_ids_of_undelivered_message_status(prefix) do
    from(s in SendSms, where: (s.delivery_status == "Sent" or is_nil(s.delivery_status)) and s.error_code == "000")
    |> Repo.all(prefix: prefix)
    |> Enum.group_by(&(&1.job_id))
    |> Enum.map(fn {job_id, _sms_list} -> job_id end)
  end

  def update_send_sms_by_message_id(message_id, delivery_status, date_time, prefix) do
    get_send_sms_by_message_id(message_id, prefix)
    |> update_send_sms(%{"delivery_status" => delivery_status, "date_time" => date_time}, prefix)
  end

  def list_message_templates do
    Repo.all(MessageTemplates)
  end

  def get_message_templates!(id), do: Repo.get!(MessageTemplates, id)

  def get_message_template_by_code(code), do: Repo.get_by(MessageTemplates, code: code)

  def create_message_templates(attrs \\ %{}) do
    %MessageTemplates{}
    |> MessageTemplates.changeset(attrs)
    |> Repo.insert()
  end

  def update_message_templates(%MessageTemplates{} = message_templates, attrs) do
    message_templates
    |> MessageTemplates.changeset(attrs)
    |> Repo.update()
  end

  def delete_message_templates(%MessageTemplates{} = message_templates) do
    Repo.delete(message_templates)
  end

  def change_message_templates(%MessageTemplates{} = message_templates, attrs \\ %{}) do
    MessageTemplates.changeset(message_templates, attrs)
  end

  def form_and_send_sms(code, mobile_no, list_of_values, prefix) do
    message_templates = get_message_template_by_code(code)
    text = form_message_text(message_templates.message, list_of_values)
    # IO.inspect(text)
    SmsSender.send_sms(mobile_no, message_templates.dlt_template_id, message_templates.telemarketer_id, text, prefix)
  end

  defp form_message_text(message, list_of_values) do
    key_value =
      Enum.reduce(list_of_values, [], fn value, acc ->
        [{"var#{length(acc) + 1}" |> String.to_atom, value} | acc]
      end)
      IO.inspect(key_value)

    EEx.eval_string(message, key_value)

  end
end

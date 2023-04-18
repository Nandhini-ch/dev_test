defmodule Inconn2Service.Communication do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Communication.SendSms

  def list_send_sms do
    Repo.all(SendSms)
  end

  def get_send_sms!(id), do: Repo.get!(SendSms, id)

  def get_send_sms_by_message_id(nil), do: []
  def get_send_sms_by_message_id(message_id), do: Repo.get_by(SendSms, message_id: message_id)


  def create_send_sms(attrs \\ %{}) do
    %SendSms{}
    |> SendSms.changeset(attrs)
    |> Repo.insert()
  end

  def update_send_sms(%SendSms{} = send_sms, attrs) do
    send_sms
    |> SendSms.changeset(attrs)
    |> Repo.update()
  end

  def delete_send_sms(%SendSms{} = send_sms) do
    Repo.delete(send_sms)
  end

  def change_send_sms(%SendSms{} = send_sms, attrs \\ %{}) do
    SendSms.changeset(send_sms, attrs)
  end

  def get_job_ids_of_undelivered_message_status() do
    from(s in SendSms, where: s.delivery_status == "Sent" or is_nil(s.delivery_status))
    |> Repo.all()
    |> Enum.group_by(&(&1.job_id))
    |> Enum.map(fn {job_id, _sms_list} -> job_id end)
  end

  def update_send_sms_by_message_id(message_id, delivery_status, date_time) do
    get_send_sms_by_message_id(message_id)
    |> update_send_sms(%{"delivery_status" => delivery_status, "date_time" => date_time})
  end
end

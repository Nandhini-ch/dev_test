defmodule Inconn2Service.Communication.SmsSender do
  use GenServer

  alias Inconn2Service.Communication
  alias Inconn2Service.Account

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def send_sms(number, dlt_template_id, telemarketer_id, text, prefix) do
    GenServer.cast(__MODULE__, {:send_sms, {number, dlt_template_id, telemarketer_id, text, prefix}})
  end

  @impl true
  def init(_args) do
    {:ok, Process.send_after(self(), :check_status, 60000)}
  end

  @impl true
  def handle_info(:check_status, _state) do
    update_delivery_status()
    {:noreply, Process.send_after(self(), :check_status, 60000)}
  end

  @impl true
  def handle_cast({:send_sms, {number, dlt_template_id, telemarketer_id, text, prefix}}, state) do
    IO.inspect("><---------------><")
    url = "http://panel.smsmessenger.in/api/mt/SendSMS"
    headers = ["Accept": "Application/json; Charset=utf-8"]

    params =
    %{
      "user" => "wynwy",
      "password" => "Wynwy@ba",
      "channel" => "Trans",
      "DCS" => "0",
      "flashsms" => "0",
      "number" => number,
      "senderid" => "WYNWYT",
      "DLTTemplateId" => dlt_template_id,
      "TelemarketerId" => telemarketer_id,
      "text" => "\"" <> text <> "\""
    }
    # |> IO.inspect()
    # IO.inspect(text)
    IO.inspect("Dear USER, (1234) is the OTP generated for the Inconn application of password reset. OTP will be valid for 15 minutes. Do not disclose to anyone Regards, Team Inconn - Wynwy")

    response = HTTPoison.get(url, headers, [params: params])

    case response do
      {:ok, %{body: body}} ->
        body = Jason.decode!(body)
        insert_data_into_table(body, params, prefix)
        {:noreply, state}
      {:error, %{reason: reason}} ->
        {:error, reason}
    end

    {:noreply, state}
  end

  defp insert_data_into_table(body, params, prefix) do
    IO.inspect(body)

    Enum.map(body["MessageData"], fn map ->
      IO.inspect(map)
      %{
        "error_code" => body["ErrorCode"],
        "error_message" => body["ErrorMessage"],
        "job_id" => body["JobId"],
        "message_id" => map["MessageId"],
        "mobile_no" => map["Number"],
        "template_id" => params["DLTTemplateId"],
        "telemarketer_id" => params["TelemarketerId"],
        "message" => params["text"]
      }
      |> IO.inspect()
      |> Communication.create_send_sms(prefix)
      |> IO.inspect()
    end)
  end

  def update_delivery_status() do
    Account.list_sub_domains()
    |> Enum.map(fn sub_domain ->
      Communication.get_job_ids_of_undelivered_message_status("inc_" <> sub_domain)
      |> Enum.map(fn job_id -> check_status(job_id, "inc_" <> sub_domain) end)
    end)
  end

  defp check_status(job_id, prefix) do
    # check_url = "http://panel.smsmessenger.in/api/mt/GetDelivery"
    headers = ["Accept": "Application/json; Charset=utf-8"]
    url = "http://panel.smsmessenger.in/api/mt/GetDelivery?user=wynwy&password=Wynwy@ba&jobid=#{job_id}"

    # check_params =
    # %{
    #   "user" => "wynwy",
    #   "password" => "Wynwy@ba",
    #   "job_id" => job_id
    # }

    check_response = HTTPoison.get(url, headers)

    case check_response do
      {:ok, %{body: body}} ->
        body = Jason.decode!(body)
        IO.puts("!!!!!!!!!!!body!!!!!!!!!!!!!!")
        IO.inspect(body)
        body["DeliveryReports"]
        |> Enum.map(fn map ->  Communication.update_send_sms_by_message_id(map["MessageId"], map["DeliveryStatus"], map["DeliveryDate"], prefix) end)


        {:ok, body}
      {:error, %{reason: reason}} ->
        {:error, reason}
    end
  end

end

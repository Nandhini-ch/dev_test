defmodule Inconn2Service.Communication.SmsSender do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  def send_sms(mobile_number, content) do
    GenServer.cast(__MODULE__, {:send_sms, {mobile_number, content}})
  end

  def init(_args) do
    {:ok, []}
  end

  # def handle_cast({:send_sms, {mobile_number, content}}, state) do
  #   {:noreply, state}
  # end
end

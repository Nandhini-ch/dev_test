defmodule Inconn2Service.Batch.AlertEscalationGenServer do
  use GenServer
  alias Inconn2Service.Common

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, Process.send_after(self(), :alert_escalation, 10000)}
  end

  def handle_info(:alert_escalation, _state) do
    Common.generate_alert_escalations()
    {:noreply, Process.send_after(self(), :alert_escalation, 10000)}
  end
end

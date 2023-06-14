defmodule Inconn2Service.Batch.AlertNotificationGenServer do
  use GenServer
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Batch.AlertNotificationGenServer
  alias Inconn2Service.Common.AlertNotificationGenerator
  alias Inconn2Service.Prompt

  def start_link(_args) do
    GenServer.start_link(AlertNotificationGenServer, [], name: AlertNotificationGenServer)
  end

  def init(_args) do
    {:ok, Process.send_after(self(), :alert_notification, 10000)}
  end

  def handle_info(:alert_notification, _state) do
    IO.puts(DateTime.utc_now)
    generate_alert_notifications()
    {:noreply, Process.send_after(self(), :alert_notification, 300000)}
  end

  def generate_alert_notifications() do
    dt = DateTime.add(DateTime.utc_now, 60, :second)
    an = from(an in AlertNotificationGenerator, where: an.utc_date_time <= ^dt) |> Repo.all
    Enum.map(an, fn x -> Prompt.generate_alert_notification_for_assets(x) end)
  end
end

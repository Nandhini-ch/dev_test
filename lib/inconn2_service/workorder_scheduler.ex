defmodule Inconn2Service.Batch.WorkorderScheduler do
  use GenServer
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Batch.WorkorderScheduler
  alias Inconn2Service.Workorder
  alias Inconn2Service.Common.WorkScheduler

  def start_link(_args) do
    GenServer.start_link(WorkorderScheduler, [], name: WorkorderScheduler)
  end

  def init(_args) do
    {:ok, Process.send_after(self(), :schedule, 10000)}
  end

  def handle_info(:schedule, _state) do
    IO.puts(DateTime.utc_now)
    get_workorder_schedulers()
    {:noreply, Process.send_after(self(), :schedule, 300000)}
  end

  def get_workorder_schedulers() do
    dt = DateTime.add(DateTime.utc_now, 300, :second)
    w = from(w in WorkScheduler, where: w.utc_date_time <= ^dt) |> Repo.all
    Enum.map(w, fn x -> Workorder.work_order_creation(x.workorder_schedule_id, x.prefix, x.zone) end)
  end
end

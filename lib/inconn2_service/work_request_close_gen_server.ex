defmodule Inconn2Service.WorkRequestCloseGenServer do
  use GenServer
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Ticket
  alias Inconn2Service.Common.WorkRequestCloseScheduler

  def start_link(_args) do
    GenServer.start_link(WorkRequestCloseGenServer, [], name: WorkRequestCloseGenServer)
  end

  def init(_args) do
    {:ok, Process.send_after(self(), :schedule, 10000)}
  end

  def handle_info(:schedule, _state) do
    IO.puts(DateTime.utc_now)
    get_work_request_close_gen_server()
    {:noreply, Process.send_after(self(), :schedule, 120000)}
  end

  def get_work_request_close_gen_server() do
    dt = DateTime.add(DateTime.utc_now, 300, :second)
    w = from(w in WorkRequestCloseScheduler, where: w.utc_date_time <= ^dt) |> Repo.all
    Enum.map(w, fn x -> Ticket.get_and_update_work_request_close_scheduler(x) end)
  end
end

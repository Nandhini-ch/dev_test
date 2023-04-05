defmodule Inconn2Service.Communication.EmailSender do
  use GenServer
  import Swoosh.Email

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  def send_email(name, email, subject_string, body_string) do
    GenServer.cast(__MODULE__, {:send_email, {name, email, subject_string, body_string}})
  end

  def init(_args) do
    {:ok, []}
  end

  def handle_cast({:send_email, {name, email, subject_string, body_string}}, state) do
      new()
      |> to({name, email})
      |> from({"Inconn Support", "info@inconn.com"})
      |> subject(subject_string)
      |> text_body(body_string)
      |> Inconn2Service.Mailer.deliver!()

    {:noreply, state}
  end
end

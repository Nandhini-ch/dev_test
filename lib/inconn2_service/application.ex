defmodule Inconn2Service.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Inconn2Service.Repo,
      # Start the Telemetry supervisor
      Inconn2ServiceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Inconn2Service.PubSub},
      #Start the Workorder GenServer
      Inconn2Service.Batch.WorkorderScheduler,
      #Start the alert and notification GenServer
      Inconn2Service.Batch.AlertNotificationGenServer,
      #Start the escalation GenServer
      # Inconn2Service.Batch.AlertEscalationGenServer,
      # Start the Endpoint (http/https)
      Inconn2ServiceWeb.Endpoint
      # Start a worker by calling: Inconn2Service.Worker.start_link(arg)
      # {Inconn2Service.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Inconn2Service.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Inconn2ServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

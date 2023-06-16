defmodule Inconn2ServiceWeb.SlaEmailConfigController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.SlaEmailConfig

  action_fallback Inconn2ServiceWeb.FallbackController

  # def index(conn, _params) do
  #   sla = ContractManagement.list_sla(conn.assigns.sub_domain_prefix)
  #   render(conn, "index.json", sla: sla)
  # end

  def index(conn, _params) do
    sla_email_config = ContractManagement.list_sla_email_config(conn.assigns.sub_domain_prefix)
    IO.inspect(sla_email_config)
    render(conn, "index.json", sla_email_config: sla_email_config)
  end

  def create(conn, %{"slaEmailConfig" => sla_email_config_params}) do
    with {:ok, %SlaEmailConfig{} = sla_email_config} <-
           ContractManagement.create_sla_email_config(
             sla_email_config_params,
             conn.assigns.sub_domain_prefix
           ) do
      conn
      |> put_status(:created)
      |> render("show.json", sla_email_config: sla_email_config)
    end
  end

  def show(conn, %{"id" => id}) do
    sla_email_config =
      ContractManagement.get_sla_email_config!(id, conn.assigns.sub_domain_prefix)

    render(conn, "show.json", sla_email_config: sla_email_config)
  end

  def update(conn, %{"id" => id, "sla_email_config" => sla_email_config_params}) do
    sla_email_config =
      ContractManagement.get_sla_email_config!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SlaEmailConfig{} = sla_email_config} <-
           ContractManagement.update_sla_email_config(
             sla_email_config,
             sla_email_config_params,
             conn.assigns.sub_domain_prefix
           ) do
      render(conn, "show.json", sla_email_config: sla_email_config)
    end
  end
end

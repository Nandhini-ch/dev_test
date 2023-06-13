defmodule Inconn2ServiceWeb.SlaEmailConfigView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SlaEmailConfigView

  def render("index.json", %{sla_email_config: sla_email_config}) do
    %{data: render_many(sla_email_config, SlaEmailConfigView, "sla_email_config.json")}
  end

  def render("show.json", %{sla_email_config: sla_email_config}) do
    %{data: render_one(sla_email_config, SlaEmailConfigView, "sla_email_config.json")}
  end

  def render("sla_email_config.json", %{sla_email_config: sla_email_config}) do
    %{
      id: sla_email_config.id,
      category: sla_email_config.category,
      email_list: sla_email_config.email_list
    }
  end
end

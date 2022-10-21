defmodule Inconn2ServiceWeb.ReferenceUpdateController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceDataUpdater
  action_fallback Inconn2ServiceWeb.FallbackController


  def update_table(conn, params) do
    content = params["csv_file"]
    ReferenceDataUpdater.update_table(content, params["table"], conn.assigns.sub_domain_prefix)
    render(conn, "message.json", %{success: true})
  end

end

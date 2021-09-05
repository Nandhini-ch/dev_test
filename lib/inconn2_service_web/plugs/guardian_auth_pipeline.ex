defmodule Inconn2ServiceWeb.Plugs.GuardianAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :inconn2_service,
    module: Inconn2Service.Guardian,
    error_handler: Inconn2ServiceWeb.Plugs.AuthErrorhandler

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, ensure: true)
end

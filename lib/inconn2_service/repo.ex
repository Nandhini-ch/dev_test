defmodule Inconn2Service.Repo do
  use Ecto.Repo,
    otp_app: :inconn2_service,
    adapter: Ecto.Adapters.Postgres
end

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config(:inconn2_service, Inconn2Service.Guardian,
  issuer: "inconn2_service",
  secret_key: "OkNc+EnFCB1BvEdM1OHOFItlvhcrx2IObsGBQGRu74xET6V9AGdAhCq7VeTK7NZT"
)

config(:inconn2_service,
  ecto_repos: [Inconn2Service.Repo]
)

# Configures the endpoint
config :inconn2_service, Inconn2ServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JsqawJLYFQePaZa/hie1D1Rq4HXuJfYEQfgYb4/lzIRNekRn7r1E1gt8spT73rGO",
  render_errors: [view: Inconn2ServiceWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Inconn2Service.PubSub,
  live_view: [signing_salt: "T0A+4aJ7"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Triplex configuration
config :triplex,
  repo: Inconn2Service.Repo,
  tenant_prefix: "inc_"

# Tzdata configuration
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :inconn2_service,
  ecto_repos: [Inconn2Service.Repo]

config :inconn2_service, Inconn2Service.Guardian,
  issuer: "inconn2_service",
  secret_key: "OkNc+EnFCB1BvEdM1OHOFItlvhcrx2IObsGBQGRu74xET6V9AGdAhCq7VeTK7NZT"

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

# config :inconn2_service, Inconn2Service.Mailer,
#   adapter: Bamboo.SMTPAdapter,
#   server: "smtp.office365.com",
#   hostname: "inconn.com",
#   port: 587,
#   username: "info@inconn.com", # or {:system, "SMTP_USERNAME"}
#   password: "Wynwy@!$", # or {:system, "SMTP_PASSWORD"}
#   tls: :if_available, # can be `:always` or `:never`
#   allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma separated values (e.g. "tlsv1.1,tlsv1.2")
#   tls_log_level: :error,
#   # tls_verify: :verify_peer, # optional, can be `:verify_peer` or `:verify_none`
#   # tls_cacertfile: "/somewhere/on/disk", # optional, path to the ca truststore
#   # tls_cacerts: "…", # optional, DER-encoded trusted certificates
#   # tls_depth: 3, # optional, tls certificate chain depth
#   tls_verify_fun: {&:ssl_verify_hostname.verify_fun/3, check_hostname: "example.com"}, # optional, tls verification function
#   ssl: false, # can be `true`
#   retries: 1,
#   no_mx_lookups: false, # can be `true`
#   auth: :if_available # can be `:always`. If your smtp relay requires authentication set it to `:always`.

config :inconn2_service, Inconn2Service.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "smtp.office365.com",
  username: "info@inconn.com",
  password: "Wynwy@!$",
  tls: :always,
  auth: :always,
  port: 587


# Tzdata configuration
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

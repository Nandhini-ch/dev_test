defmodule Inconn2Service.MixProject do
  use Mix.Project

  def project do
    [
      app: :inconn2_service,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      # compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Inconn2Service.Application, []},
      extra_applications: [:logger, :runtime_tools, :pdf_generator]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.10"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 2.0"},
      {:triplex, "~> 1.3"},
      {:tzdata, "~> 1.1"},
      {:ecto_commons, "~> 0.3.3"},
      {:comeonin, "~> 5.1.2"},
      {:argon2_elixir, "~> 2.0"},
      {:guardian, "~> 1.0"},
      {:csv, "~> 2.4"},
      {:pdf_generator, ">=0.6.0"},
      {:eqrcode, "~> 0.1.10"},
      {:sneeze, "~> 1.2"},
      {:swoosh, "~> 1.6"},
      {:gen_smtp, "~>  1.2"},
      {:httpoison, "~> 2.0"},
      {:image, "~> 0.33.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "ecto.create_alert_notification_reserves",
        "run priv/repo/seeds.exs",
        # "run priv/repo/seed_alerts_tenant.exs",
        "run priv/repo/seeds_party_site.exs",
        "run priv/repo/seeds_shifts.exs",
        "run priv/repo/seeds_holiday.exs",
        "run priv/repo/seed_create_employee_user.exs",
        "run priv/repo/seed_inventory.exs",
        "run priv/repo/seeds_work_order.exs",
        "run priv/repo/seed_induce_alerts_and_notifications.exs",
        "run priv/repo/seed_inventory_management.exs",
      ],
      "ecto.setup_coco": [
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seed_coco.exs",
        "run priv/repo/seed_employee_user_coco.exs",
        ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.reset_coco": ["ecto.drop", "ecto.setup_coco"],
      "ecto.create_timezones": ["run priv/repo/seed_timezones.exs"],
      "ecto.create_alert_notification_reserves": ["run priv/repo/seed_alerts.exs"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
